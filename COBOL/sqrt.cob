*> ------------------------------------------------------------------
*> -                    Babylonian Square Roots                     -
*> -                  Re-engineered with love. <3                   -
*> -                   by Jason Nguyen (1013950)                    -
*> ------------------------------------------------------------------

identification division.
program-id. sqrtbaby.

environment division.

data division.

working-storage section.
77 radicand    pic s9(20)v9(10). *> Original number, or N
77 guess       pic s9(20)v9(10). *> First guess, or R0
77 prevGuess   pic s9(20)v9(10). *> Second guess, or R1
77 answer      pic z(20).z(10).  *> Second guess, but formatted

*> --------------------------Main Program----------------------------

procedure division.

    display "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".
    display "~       Babylonian Square Root Calculator        ~".
    display "~                by Jason Nguyen                 ~".
    display "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".

    *> Prompt user for input until they enter 0 to exit
    perform with test after until radicand = 0

        *> Text prompt for user
        display "Enter a number (or 0 to exit): " with no advancing

        *> Capturing user input (stdin)
        accept radicand end-accept

        *> Proceeds if number is valid (in sqrt(x), x must be >= 0)
        if radicand is > 0 then

            *> Our initial guess will be half the number
            divide 2 into radicand giving guess rounded

            *> Iterate until we are accurate enough
            perform with test after until
            function abs(guess - prevGuess) < 0.000001

                *> Store the last guess
                move guess to prevGuess

                *> Compute the next iteration
                compute
                    guess rounded = (prevGuess+radicand / prevGuess) / 2
                end-compute

            end-perform

            *> Format the final guess
            move guess to answer

            *> Display it. We use the trim() function to remove spaces
            display "Square root is " with no advancing
            display function trim(answer leading)
            display " "

        else

            *> 0 is a sentinel value to check if the user wants to exit
            if radicand is = 0 then
                display "Good bye. Thank you for using my program!"
                display " "
                
            *> Everything else after this is considered invalid
            else
                display "Invalid input! Re-try"
                display " "

            end-if

        end-if

    end-perform

    stop run.

*> ------------------------------------------------------------------
