# Makefile
# This is an example Makefile to help you get familiar with GNU Make
# and get started with using it to automate your project build tasks.
# For the full GNU Make manual, see:
# https://www.gnu.org/software/make/manual/make.html
#
# A Makefile consists of rules, which take following form:
# target … : prerequisites …
#        recipe
#        …
#        …
#
# Multiple targets and prerequisites are separated by spaces;
# multiple recipes are separated by newlines.
#
# If the target file exists, and the file has not been modified since any
# of its prerequisite files were last modified, the rule will be skipped.
# This means that it won't redo any work that it doesn't need to!
#
# Some things to note:
# - Indentation must be tabs--Make will error if you use spaces.
# - To break a long line, use a backslash: \
# - If you just type "make" at the command line in the directory
# where the Makefile is, it will run the first recipe
# (after running its prerequisites).
# - Other than that, the ordering of the rules in the file doesn't matter.
# Make builds a dependency graph and performs a topological sort to determine
# the correct rule execution order.
# - If you just type "make" it will run the first rule in the file.
# - If you type "make {rule name}" it will run that specific rule name
# (again, after running its prerequisites).
# - If you type "make -n" it will tell you what it's going to run without
# actually running it (a dry run).
#
# Rules can either be file names (a rule for producing a file)
# or just task names that aren't files, called "phony rules."
# List any phony rules here so that Make knows not to look for files
# by these names:
.PHONY : all test leak zip
CC = g++
STD = -std=c++11
#PT = -lpthread   //used for pthread
CFLAGS = -g -O0 -Wextra $(STD) \
#CFLAGS = -g -O0 -Wall -Wextra $(STD) \
#	-fsanitize=address -fsanitize=leak -fsanitize=undefined -fno-sanitize-recover
#	-fsanitize=thread  -fsanitize=undefined -fno-sanitize-recover  //used to check leaks


# Because "make" runs the first rule in the file, make the first rule
# inclusive of the other rules in your Makefile:
all : driver.out

# A rule to make the main executable:
driver.out : driver.cpp server.cpp client.cpp
	$(CC) $(CFLAGS) $(PT) server.cpp client.cpp $< -o $@ 

# A rule to compile the main file for use by the tests.
# Uses a #define macro to replace `main` with `notmain` because
# a C++ program can only have one `main` function.
driver.o : driver.cpp 
	$(CC) $(CFLAGS) -Dmain=notmain $< -c -o $@

# A rule to compile the test executable
test_driver.out : test_driver.cpp driver.cpp server.cpp client.cpp driver.o test.o
	$(CC) $(CFLAGS) test_driver.cpp UdpMulticast.cpp driver.o test.o -o $@

# A rule to run your tests:
test : test_driver.out
	./$< -s

# A rule to run your leak tests with valgrind:
leak : driver.out
	valgrind --leak-check=full ./$< [need to put params here]

# A rule to compile the "dummy" main for Catch2
test.o : test.cpp catch.hpp
	$(CC) $(STD) $< -c -o $@

# A rule to zip the source files
zip : driver.zip

# A rule to make the zip file
driver.zip : $(wildcard *.cpp) $(wildcard *.h) $(wildcard *.hpp) $(wildcard *.pdf) Makefile
	zip $@ $^

# A rule to delete all compiled files and leave only source code behind
clean :
	rm *.out
	rm *.o
	rm *.zip
