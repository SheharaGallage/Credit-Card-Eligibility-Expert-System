% Automated test cases for credit_card_es.pl
:- begin_tests(credit_card_es).
:- consult('credit_card_es.pl').

clear_test_data :- retractall(answer(_, _)).

test(tc01_all_three_cards, [setup(clear_test_data), cleanup(clear_test_data)]) :-
    maplist(assertz, [
        answer(age,30), answer(id_type,nic), answer(employment,salaried),
        answer(permanent_employment,yes), answer(gross_income,550000),
        answer(net_income,350000), answer(salary_evidence,yes),
        answer(variable_income_proof,yes), answer(has_fixed_allowances,no),
        answer(fixed_allowance_proof,not_applicable),
        answer(address_differs,no), answer(billing_proof,not_applicable)
    ]),
    eligible_for(platinum), eligible_for(signature), eligible_for(infinite).

test(tc02_platinum_only, [setup(clear_test_data), cleanup(clear_test_data)]) :-
    maplist(assertz, [
        answer(age,25), answer(id_type,nic), answer(employment,salaried),
        answer(permanent_employment,yes), answer(gross_income,150000),
        answer(net_income,120000), answer(salary_evidence,yes),
        answer(variable_income_proof,yes), answer(has_fixed_allowances,no),
        answer(fixed_allowance_proof,not_applicable),
        answer(address_differs,no), answer(billing_proof,not_applicable)
    ]),
    eligible_for(platinum),
    \+ eligible_for(signature),
    \+ eligible_for(infinite).

test(tc03_below_minimum_age, [setup(clear_test_data), cleanup(clear_test_data)]) :-
    maplist(assertz, [
        answer(age,17), answer(id_type,nic), answer(employment,salaried),
        answer(permanent_employment,yes), answer(gross_income,600000),
        answer(net_income,400000), answer(salary_evidence,yes),
        answer(variable_income_proof,yes), answer(has_fixed_allowances,no),
        answer(fixed_allowance_proof,not_applicable),
        answer(address_differs,no), answer(billing_proof,not_applicable)
    ]),
    \+ general_requirements_complete,
    \+ eligible_for(platinum),
    \+ eligible_for(signature),
    \+ eligible_for(infinite).

test(tc04_missing_salary_evidence, [setup(clear_test_data), cleanup(clear_test_data)]) :-
    maplist(assertz, [
        answer(age,30), answer(id_type,passport), answer(employment,salaried),
        answer(permanent_employment,yes), answer(gross_income,550000),
        answer(net_income,350000), answer(salary_evidence,no),
        answer(variable_income_proof,yes), answer(has_fixed_allowances,no),
        answer(fixed_allowance_proof,not_applicable),
        answer(address_differs,no), answer(billing_proof,not_applicable)
    ]),
    \+ salaried_documents_complete,
    \+ eligible_for(platinum),
    \+ eligible_for(signature),
    \+ eligible_for(infinite).

test(tc05_self_employed_complete, [setup(clear_test_data), cleanup(clear_test_data)]) :-
    maplist(assertz, [
        answer(age,35), answer(id_type,nic), answer(employment,self_employed),
        answer(business_registration,yes), answer(business_type_documents,yes),
        answer(business_statements_6_months,yes),
        answer(auditor_letter_2_years,yes),
        answer(latest_tax_return,yes), answer(latest_tax_receipts,yes)
    ]),
    self_employed_published_requirements_complete.

test(tc06_self_employed_incomplete, [setup(clear_test_data), cleanup(clear_test_data)]) :-
    maplist(assertz, [
        answer(age,35), answer(id_type,driving_license),
        answer(employment,self_employed), answer(business_registration,yes),
        answer(business_type_documents,yes),
        answer(business_statements_6_months,no),
        answer(auditor_letter_2_years,yes),
        answer(latest_tax_return,yes), answer(latest_tax_receipts,no)
    ]),
    \+ business_statement_evidence_complete,
    \+ tax_receipt_evidence_complete,
    \+ self_employed_published_requirements_complete.

:- end_tests(credit_card_es).
