NDB CREDIT CARD EXPERT SYSTEM 


This expert system was developed using SWI-Prolog. It evaluates applicant
information against published requirements for selected NDB credit cards.

## Requirements

- SWI-Prolog

## How to Run

1. Download or clone this repository.
2. Open SWI-Prolog.
3. Load `credit_card_es_FINAL.pl`.
4. Run:

   ?- start.

5. Enter each answer followed by a full stop (`.`).

Example:

   30.
   nic.
   salaried.
   yes.

6. To check another applicant, run:

   ?- start.

7. To exit SWI-Prolog, run:

   ?- halt.

## Running Test Cases

Load the test file:

   ?- [test_credit_card_es].

Then run the tests as described in the source file.

## Knowledge Sources

The rules were derived from official NDB Bank credit-card information.
The full source references and rule mappings are provided in the assignment report.

test test cases 

1. Load tests:
   ?- [test_credit_card_es].
2. Run all tests:
   ?- run_tests.

TC01: Salaried applicant satisfies all three represented card requirements.
TC02: Salaried applicant satisfies Platinum only.
TC03: Applicant is below minimum age.
TC04: Salaried applicant is missing salary evidence.
TC05: Self-employed document requirements are complete.
TC06: Self-employed document requirements are incomplete.
