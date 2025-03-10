#!/usr/bin/env fish

set TEST_DIR tests
set TAPES $TEST_DIR/tapes
set REFERENCES $TEST_DIR/references
set TEMP $TEST_DIR/tmp

set EZA_GREEN 0D0
set EZA_RED D00
set EZA_YELLOW DD0

alias ffmpeg="echo skipping ffmpeg" 

function print_msg -a ARG -a OP -a NAME -a MSG
    # Write operator, e.g. [+]
    # [*]: indicates neutral result
    # [+]: indicates positive result
    # [-]: indicates negative result
    set_color reset
    echo -n "[$OP] "

    # Write source, e.g. [ blocksize ]:
    set_color reset
    set_color -b $ARG
    set_color 000
    echo -n "[ $NAME ]:"

    # Write message, e.g.
    set_color reset
    echo " $MSG"

    set_color reset
end

function run_test -d "Run VHS test" -a NAME

    set FUNCTION_NAME "$NAME > run_test"

    set NAME_TAPE "$NAME.tape"

    set SUCCESS (print_msg "$EZA_GREEN" "+" "$FUNCTION_NAME" "Success")
    set FAILURE (print_msg "$EZA_RED" "-" "$FUNCTION_NAME" "Failure")

    set GEN_DIR $TEMP
    set GEN_FILE $GEN_DIR/$NAME.txt
    set GEN_FILE_ESCAPE (echo $GEN_FILE | sed "s/\//\\\\\//g")

    print_msg $EZA_YELLOW "*" $FUNCTION_NAME "Testing..."

    cat $TAPES/$NAME_TAPE | sed s/outfile/$GEN_FILE_ESCAPE/ | vhs &>/dev/null

    cmp -s -- $REFERENCES/$NAME.txt $TEMP/$NAME.txt && echo $SUCCESS || echo $FAILURE
end

function gen_test -d "Generate VHS test" -a NAME

    set FUNCTION_NAME "$NAME > gen_test"

    set NAME_TAPE "$NAME.tape"

    set SUCCESS (print_msg "$EZA_GREEN" "+" "$FUNCTION_NAME" "Success")
    set FAILURE (print_msg "$EZA_RED" "-" "$FUNCTION_NAME" "Failure")

    set GEN_DIR $REFERENCES
    set GEN_FILE $GEN_DIR/$NAME.txt
    set GEN_FILE_ESCAPE (echo $GEN_FILE | sed "s/\//\\\\\//g")

    # The idea behind this is that it makes it easier for users of this system
    # to change the reference. They should now only have to delete the old
    # reference, and a new one will be generated.
    if builtin test -f $GEN_FILE
        print_msg $EZA_GREEN "+" $FUNCTION_NAME "$GEN_FILE exists"
        return
    end

    print_msg $EZA_YELLOW "*" $FUNCTION_NAME "Generating..."

    cat $TAPES/$NAME_TAPE | sed s/outfile/$GEN_FILE_ESCAPE/ | vhs &>/dev/null && echo $SUCCESS || echo $FAILURE

end

gen_test $argv[1]
run_test $argv[1]
