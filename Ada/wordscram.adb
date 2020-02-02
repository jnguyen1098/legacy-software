with Ada.Text_IO; use Ada.Text_IO;
with Ada.Assertions; use Ada.Assertions;
with Ada.Numerics.Discrete_Random;
with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;
--with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
--with Ada.Strings.Unbounded.Text_IO; use Ada.Strings.Unbounded.Text_IO;

procedure Wordscram is

-------------------------- Main Subprograms ---------------------------

    procedure getFilename(File_Name : out String; Len : out Integer);
    function processText(File_Name : String) return Integer;
    procedure scrambleWord(Str : in out String; Len : in Integer);
    function randomInt(A : Integer; B : Integer) return Integer;
    function isWord(Str : String) return Boolean;

    function Does_File_Exist(Name : String) return Boolean;

-----------------------------------------------------------------------

    -- Verifies a filename and returns it to main
    procedure getFilename(File_Name : out String; Len : out Integer) is
    begin
        loop
            Put("File name to open: ");
            Get_Line(File_Name, Len);
            if (Does_File_Exist(File_Name(File_Name'First .. Len))
                    = False) then
                Put_Line("Could not open file! Re-try.");
                New_Line;
            else exit;
            end if;
        end loop;
    end getFilename;

    -- Helper function to verify if file exists
    function Does_File_Exist(Name : String) return Boolean is
        Fp : Ada.Text_IO.File_Type;
    begin
        -- Asking for forgiveness . . . 
        Open(Fp, In_File, Name);
        Close(Fp);
        return True;

    exception
        -- . . . rather than permission. :-)
        when Name_Error =>
            return False;
    end Does_File_Exist;

    -- Processes the words within a file
    function processText(File_Name : String) return Integer is
    Word_Count : Integer := 0;
            Fp : Ada.Text_IO.File_Type;
    begin
        -- Attempt to open the file for playback
        Open(File => Fp,
             Mode => In_File,
             Name => File_Name);

        -- Print every original line
        Put_Line("                      O r i g i n a l      T e x t");
        Put_Line("--------------------------------------------------" &
                 "----------------------");
        while not End_Of_File(Fp) loop
            Put_Line(Get_Line(Fp));
        end loop;
        New_Line;
        Close(Fp);

        -- Attempt to open the file again, this time for processing
        Open(File => Fp,
             Mode => In_File,
             Name => File_Name);

        -- Process every line
        Put_Line("                      T r a n s p o s e d  T e x t");
        Put_Line("--------------------------------------------------" &
                 "----------------------");
        while not End_Of_File(Fp) loop
        declare
             Left : Integer := 1;
            Right : Integer := 1;
             Line : String := Get_Line(Fp);
        begin

            while Left <= Line'Length and then Right <= Line'Length loop
                if isWord(Line(Left .. Right)) = False then
                    Put(Line(Left .. Right));
                    Left := Left + 1;
                    Right := Right + 1;
                else
                    while Right <= Line'Length and then
                    isWord(Line(Left .. Right)) loop
                        Right := Right + 1;
                    end loop;
                    Right := Right - 1;
                    scrambleWord(Line(Left .. Right), Right - Left + 1);
                    Put(Line(Left .. Right));

                    Word_Count := Word_Count + 1;

                    Right := Right + 1;
                    Left := Right;

                end if;
            end loop;

            New_Line;

        end;
        end loop;

        -- Close the file when we are done and return word count
        Close(Fp);
        return Word_Count;

    end processText;

    -- Scramble a string / "word" in-place
    procedure scrambleWord(Str : in out String; Len : in Integer) is
        Copy : String := Str(Str'first + 1 .. Str'first + Len - 2);
        Rand : Integer;
    begin

        if Len > 3 then
            for i in 2 .. Len - 1 loop

                Rand := randomInt(Copy'First, Copy'Last + 1);

                loop
                    Rand := randomInt(Copy'First, Copy'Last + 1);
                    exit when Copy(Rand) /= '.';
                end loop;

                Str(Str'First + i - 1) := Copy(Rand);
                Copy(Rand) := '.';

            end loop;
        end if;

    end scrambleWord;

    -- Check if a string is completely alphabetic
    function isWord(Str : String) return Boolean is
    Ascii_Value : Integer;
    begin
        -- Check for empty string
        if Str = "" then
            return false;
        end if;

        -- Check if each character is alpha
        for i in 1 .. Str'Length loop
            Ascii_Value := Character'Pos(Str(Str'first + i - 1));
            if Ascii_Value < 65 or Ascii_Value > 122 then
                return false;
            elsif Ascii_Value > 90 and Ascii_Value < 97 then
                return false;
            end if;
        end loop;

        -- If we reach this point, it's a good string and we exit
        return true;
    end isWord;

    -- Generate a random number on the interval [A, B) (incl. - excl.)
    function randomInt(A : Integer; B : Integer) return Integer is
        subtype IntGen is Integer range A .. B - 1;
        package RandGen is new Ada.Numerics.Discrete_Random (IntGen);
        use RandGen;
        RandIntGen : Generator;
    begin
        -- Generate our number
        Reset(RandIntGen);
        return Random(RandIntGen);
    end randomInt;

------------------------- Testing Subprograms -------------------------

    procedure Test_isWord(Str : String; Expected : Boolean);
    procedure Test_randomInt(A : Integer; B : Integer);
    procedure Test_scrambleWord(Str : String);

-----------------------------------------------------------------------

    -- Tests the return value of isWord()
    procedure Test_isWord(Str : String; Expected : Boolean) is
    begin
        -- Assert word status
        Assert(isWord(Str) = Expected, "isWord(" & str & ") failed! " &
                "Expected " & Boolean'Image(Expected));
        Put_Line("    PASS: isWord(" & str & ")");
    end test_isWord;

    -- Tests the return value of randomInt()
    procedure Test_randomInt(A : Integer; B : Integer) is
    Rand_Value : Integer;
        Checks : array(-10000 .. 10000) of Integer := (others => 0);
    begin
        -- Assert all outputs are in range for 10,000 trials
        for i in 1 .. 10000 loop
            Rand_Value := randomInt(A, B);
            Checks(Rand_Value) := 1;
            Assert(Rand_Value >= A and Rand_Value < B, "randomInt(" &
                    Integer'Image(A) & "," & Integer'Image(B) &
                    ") failed!" & " Got " & Integer'Image(Rand_Value));
        end loop;
        -- Assert function is surjective / "onto" range
        for i in A .. B - 1 loop
            Assert(Checks(i) = 1, "Value " & Integer'Image(i) &
                   " not found in range [" & Integer'Image(A) & ", " &
                    Integer'Image(B) & ").");
        end loop;
        Put_Line("    PASS: randomInt(" & Integer'Image(A) & "," &
                 Integer'Image(B) & ")");
    end Test_randomInt;

    -- Tests the word scrambling of scrambleWord()
    procedure Test_scrambleWord(Str : String) is
    Copy : String := Str;
    Temp : String := Str;
    begin
        -- Scramble a copy of the word
        scrambleWord(Copy, Copy'Length);

        -- Assert that scrambleWord() creates an actual word
        Assert(isWord(Copy) = True, Copy & " is not a word!");
        
        -- Assert the two strings are the same length
        Assert(Copy'Length = Str'Length, Copy & " != " & Str);

        -- Assert that the first letters match
        Assert(Copy(Copy'First) = Str(Str'First), 
                "First letters don't match: " & Copy & " != " & Str);

        -- Assert that the last letters match
        Assert(Copy(Copy'Last) = Str(Str'Last),
                "Last letters don't match: " & Copy & " != " & Str);

        -- Confirm that the two words are anagrams by checking letters
        for i in Copy'First .. Copy'Last loop
            for j in Temp'First .. Temp'Last loop
                if Copy(i) = Temp(j) then
                    Temp(j) := '.';
                end if;
            end loop;
        end loop;

        -- Verify the guard character, the period. Because we verify
        -- that isWord() gives true, the period is free to use
        for i in Temp'First .. Temp'Last loop
            Assert(Temp(i) = '.', Copy & " and " & Str &
                   " are not anagrams!");
        end loop;

        -- Test passed at this point
        Put_Line("    PASS: scrambleWord(" & Str & ")");

    end Test_scrambleWord;

    -- Testing variables

    -- Main variables
    File_Name_Len : Integer;
        File_Name : String(1..100);
        Num_Words : Integer;

-----------------------------------------------------------------------

begin
    -- Test harness
    Put_Line(ESC & "[32m" & "Starting automatic tests!" & ESC & "[0m");

    Put_Line("Testing isWord() for true...");
    New_Line;
        Test_isWord("a", true);
        Test_isWord("z", true);
        Test_isWord("abasjdklflksdf", true);
        Test_isWord("A", true);
        Test_isWord("Z", true);
        Test_isWord("AZ", true);
        Test_isWord("ASDFJSADFJSADKFJAG", true);
        Test_isWord("ABCDEFGHIJKLMNOPQRSTUVWXYZ", true);
        Test_isWord("abcdefghijklmnopqrstuvwxys", true);
    New_Line;

    Put_Line("Testing isWord() for false...");
    New_Line;
        Test_isWord("", false);
        Test_isWord("1", false);
        Test_isWord("28375498275", false);
        Test_isWord("!", false);
        Test_isWord(" ", false);
        Test_isWord("ABa313", false);
        Test_isWord("aaskdfjaskdfashdf1", false);
        Test_isWord("hsadfjasdf[aksdjfaskdf", false);
        Test_isWord("sakdjfl`aksdjf", false);
        Test_isWord("adsf~~asdfasdf", false);
        Test_isWord("ABCDEFGHIJKL~MNOPQRSTUVWXYZ", false);
        Test_isWord("1234567890][';/.[p,p.][}{>{}>}{>{}", false);
    New_Line;

    Put_Line("Testing randomInt()...");
    New_Line;
        Test_randomInt(1, 5);
        Test_randomInt(10, 500);
        Test_randomInt(-10, 5);
        Test_randomInt(-10, 0);
        Test_randomInt(0, 50);
        Test_randomInt(-100, 100);
        Test_randomInt(-1, 0);
        Test_randomInt(1, 2);
        Test_randomInt(2, 3);
        Test_randomInt(10, 11);
        Test_randomInt(100, 101);
        Test_randomInt(1000, 1001);
    New_Line;

    Put_Line("Testing scrambleWord()...");
    New_Line;
        Test_scrambleWord("a");
        Test_scrambleWord("z");
        Test_scrambleWord("ad");
        Test_scrambleWord("hel");
        Test_scrambleWord("HASfdhasFDDFhasdf");
        Test_scrambleWord("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        Test_scrambleWord("abcdefghijklmnopqrstuvwxyz");
        Test_scrambleWord("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        Test_scrambleWord("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");
        Test_scrambleWord("ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ");
        Test_scrambleWord("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
        Test_scrambleWord("IJUSTLOSTTHEGAMEEEEEEEEEEEEEEEEEEEEEEEEEE");
        Test_scrambleWord("ABCDEFGHIJKLMNOPQRSTUVWXYZ" &
                          "abcdefghijklmnopqrstuvwxyz");
        Test_scrambleWord("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmno" &
                          "pqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZabcd" &
                          "efghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRS" &
                          "TUVWXYZabcdefghijklmnopqrstuvwxyzABCDEFGH" &
                          "IJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvw" &
                          "xyzABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijkl" &
                          "mnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZa" &
                          "bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOP" &
                          "QRSTUVWXYZabcdefghijklmnopqrstuvwxyzABCDE" &
                          "FGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrst" &
                          "uvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghi" &
                          "jklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWX" &
                          "YZabcdefABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFG");


    -- Manual testing
    New_Line;
    Put_Line(ESC & "[32m" & "Passed all automatic tests" & ESC &"[0m");
    Put_Line(ESC & "[32m" & "Starting manual tests!" & ESC & "[0m");

    New_Line;
    Put_Line("Testing 1000 most common English words...");
    Put_Line("You should be able to recognize these");
    New_Line;
    Num_Words := processText("test/test.txt");
    New_Line;
    Put_Line("Word Count: " & Integer'Image(Num_Words));

    New_Line;
    Put_Line("Testing punctuation nightmare");
    Put_Line("Punctuation should be intact; words scrambled");
    New_Line;
    Num_Words := processText("test/punctuation.txt");
    New_Line;
    Put_Line("Word Count: " & Integer'Image(Num_Words));

    New_Line;
    Put_Line("Testing 3-letter words");
    Put_Line("There should be NO change");
    New_Line;
    Num_Words := processText("test/3letter.txt");
    New_Line;
    Put_Line("Word Count: " & Integer'Image(Num_Words));

    New_Line;
    Put_Line("Testing 2-letter words");
    Put_Line("There should be NO change");
    New_Line;
    Num_Words := processText("test/2letter.txt");
    New_Line;
    Put_Line("Word Count: " & Integer'Image(Num_Words));

    New_Line;
    Put_Line("Testing 1-letter words");
    Put_Line("There should be NO change");
    New_Line;
    Num_Words := processText("test/1letter.txt");
    New_Line;
    Put_Line("Word Count: " & Integer'Image(Num_Words));

    New_Line;
    Put_Line("Testing professor's sample file");
    New_Line;
    Num_Words := processText("test/sample.txt");
    New_Line;
    Put_Line("Word Count: " & Integer'Image(Num_Words));

    New_Line;
    Put_Line(ESC & "[32m" & "All automatic tests passed!" & ESC & "[0m");
    Put_Line("Now, scroll up and manually examine your sample outputs.");
    New_Line;

    -- Main code

    getFilename(File_Name, File_Name_Len);
    New_Line;
    Num_Words := processText(File_Name(1..File_Name_Len));
    New_Line;
    Put_Line("Word count: " & Integer'Image(Num_Words));

end Wordscram;

-----------------------------------------------------------------------
