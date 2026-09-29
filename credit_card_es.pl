% ================================================================
% NDB CREDIT CARD ELIGIBILITY EXPERT SYSTEM
% Platform: SWI-Prolog
%
% Official knowledge sources used:
% S1 NDB Platinum Cards:
%    https://www.ndbbank.com/cards/credit-cards/platinum-cards
% S2 NDB Signature Cards:
%    https://www.ndbbank.com/cards/credit-cards/signature-cards
% S3 NDB Infinite Cards:
%    https://www.ndbbank.com/cards/credit-cards/infinite-cards
% S4 NDB Credit Card Application Form:
%    https://ndbbankweb.ndbbank.com/downloads/3ce8dc69-409f-441b-b75d-9df7b7500db9_credit-card-application-form---english-2.pdf
%
% Knowledge captured from S1-S3:
% - Minimum age: 18
% - Accepted identification: NIC, passport, driver's licence
% - Salaried Platinum: permanent employment + min gross income LKR 100,000
% - Salaried Signature: permanent employment + min net income LKR 300,000
% - Salaried Infinite: permanent employment + min gross income LKR 500,000
% - Salaried documents: recent certified salary slips OR employer salary letter;
%   variable-income proof for past 3 months; fixed-allowance proof;
%   billing proof when current address differs from NIC
% - Self-employed documents: business registration/supporting business-type docs;
%   business current-account statements for past 6 months;
%   certified auditor letter confirming annual income for last 2 years;
%   latest-year tax returns and payment receipts
%
% S4 states incomplete information/evidence may delay processing and that
% the credit limit is at NDB's sole discretion.
% ================================================================

:- dynamic answer/2.

% ----------------------- SOURCE FACTS ----------------------------

minimum_age(18).                                  % S1, S2, S3

accepted_id(nic).                                 % S1, S2, S3
accepted_id(passport).                            % S1, S2, S3
accepted_id(driving_license).                     % S1, S2, S3

salaried_min_income(platinum, gross, 100000).     % S1
salaried_min_income(signature, net, 300000).      % S2
salaried_min_income(infinite, gross, 500000).     % S3

% ---------------------- SYSTEM ENTRY -----------------------------

start :-
    retractall(answer(_, _)),
    nl,
    writeln('=========================================================='),
    writeln('       NDB CREDIT CARD ELIGIBILITY EXPERT SYSTEM'),
    writeln('=========================================================='),
    nl,
    ask_common_details,
    evaluate,
    nl,
    writeln('To check another applicant, type: start.'),
    writeln('To exit SWI-Prolog, type: halt.').

% ---------------------- USER INTERFACE ---------------------------

ask_common_details :-
    ask_number('Enter applicant age', Age),
    save(age, Age),

    ask_choice('Identification type (nic/passport/driving_license/none)',
               [nic, passport, driving_license, none], ID),
    save(id_type, ID),

    ask_choice('Employment type (salaried/self_employed)',
               [salaried, self_employed], Employment),
    save(employment, Employment),

    ( Employment == salaried ->
        ask_salaried_details
    ;
        ask_self_employed_details
    ).

ask_salaried_details :-
    ask_yes_no('Are you permanently employed? (yes/no)', Permanent),
    save(permanent_employment, Permanent),

    ask_number('Enter gross monthly income in LKR', Gross),
    save(gross_income, Gross),

    ask_number('Enter net monthly income in LKR', Net),
    save(net_income, Net),

    ask_yes_no('Do you have certified recent salary slips OR an employer salary letter? (yes/no)', SalaryEvidence),
    save(salary_evidence, SalaryEvidence),

    ask_yes_no('Do you have proof of variable income for the past 3 months? (yes/no)', Variable),
    save(variable_income_proof, Variable),

    ask_yes_no('Do you receive fixed allowances? (yes/no)', HasAllowances),
    save(has_fixed_allowances, HasAllowances),

    ( HasAllowances == yes ->
        ask_yes_no('Do you have proof of those fixed allowances? (yes/no)', AllowanceProof),
        save(fixed_allowance_proof, AllowanceProof)
    ;
        save(fixed_allowance_proof, not_applicable)
    ),

    ask_yes_no('Is your current address different from the address on your NIC? (yes/no)', DifferentAddress),
    save(address_differs, DifferentAddress),

    ( DifferentAddress == yes ->
        ask_yes_no('Do you have billing proof for your current address? (yes/no)', BillingProof),
        save(billing_proof, BillingProof)
    ;
        save(billing_proof, not_applicable)
    ).

ask_self_employed_details :-
    ask_yes_no('Do you have a Business Registration Certificate? (yes/no)', BR),
    save(business_registration, BR),

    ask_yes_no('Do you have documents verifying the business type? (yes/no)', BusinessTypeDocs),
    save(business_type_documents, BusinessTypeDocs),

    ask_yes_no('Do you have business current-account statements for the past 6 months? (yes/no)', Statements),
    save(business_statements_6_months, Statements),

    ask_yes_no('Do you have a certified auditor letter confirming annual income for the last 2 years? (yes/no)', Auditor),
    save(auditor_letter_2_years, Auditor),

    ask_yes_no('Do you have tax returns for the most recent year? (yes/no)', TaxReturns),
    save(latest_tax_return, TaxReturns),

    ask_yes_no('Do you have tax payment receipts for the most recent year? (yes/no)', TaxReceipts),
    save(latest_tax_receipts, TaxReceipts).

save(Key, Value) :-
    assertz(answer(Key, Value)).

ask_number(Prompt, Value) :-
    format('~w: ', [Prompt]),
    read(Input),
    ( number(Input), Input >= 0 ->
        Value = Input
    ;
        writeln('Invalid input. Enter a non-negative number followed by a period.'),
        ask_number(Prompt, Value)
    ).

ask_yes_no(Prompt, Value) :-
    format('~w: ', [Prompt]),
    read(Input),
    ( member(Input, [yes, no]) ->
        Value = Input
    ;
        writeln('Invalid input. Enter yes. or no.'),
        ask_yes_no(Prompt, Value)
    ).

ask_choice(Prompt, Choices, Value) :-
    format('~w: ', [Prompt]),
    read(Input),
    ( member(Input, Choices) ->
        Value = Input
    ;
        format('Invalid input. Choose one of ~w followed by a period.~n', [Choices]),
        ask_choice(Prompt, Choices, Value)
    ).

% ================================================================
% DECISION-MAKING RULES
% Each rule below is derived from the published requirements above.
% ================================================================

% R01 - S1/S2/S3: Applicant must be at least 18.
age_eligible :-
    answer(age, Age),
    minimum_age(Min),
    Age >= Min.

% R02 - S1/S2/S3: NIC is accepted identification.
valid_identification :-
    answer(id_type, nic).

% R03 - S1/S2/S3: Passport is accepted identification.
valid_identification :-
    answer(id_type, passport).

% R04 - S1/S2/S3: Driver's licence is accepted identification.
valid_identification :-
    answer(id_type, driving_license).

% R05 - S1/S2/S3: Published salaried criteria require permanent employment.
permanent_salaried_employee :-
    answer(employment, salaried),
    answer(permanent_employment, yes).

% R06 - S1: Platinum salaried gross monthly income >= LKR 100,000.
platinum_income_eligible :-
    permanent_salaried_employee,
    answer(gross_income, Income),
    salaried_min_income(platinum, gross, Min),
    Income >= Min.

% R07 - S2: Signature salaried net monthly income >= LKR 300,000.
signature_income_eligible :-
    permanent_salaried_employee,
    answer(net_income, Income),
    salaried_min_income(signature, net, Min),
    Income >= Min.

% R08 - S3: Infinite salaried gross monthly income >= LKR 500,000.
infinite_income_eligible :-
    permanent_salaried_employee,
    answer(gross_income, Income),
    salaried_min_income(infinite, gross, Min),
    Income >= Min.

% R09 - S1/S2/S3: Salary slips OR employer salary letter satisfies salary evidence.
salary_evidence_complete :-
    answer(salary_evidence, yes).

% R10 - S1/S2/S3: Variable-income proof for the past 3 months is required.
variable_income_evidence_complete :-
    answer(variable_income_proof, yes).

% R11 - S1/S2/S3: If fixed allowances exist, proof must be available.
fixed_allowance_evidence_complete :-
    answer(has_fixed_allowances, no).
fixed_allowance_evidence_complete :-
    answer(has_fixed_allowances, yes),
    answer(fixed_allowance_proof, yes).

% R12 - S1/S2/S3: Billing proof is needed when current address differs from NIC.
billing_evidence_complete :-
    answer(address_differs, no).
billing_evidence_complete :-
    answer(address_differs, yes),
    answer(billing_proof, yes).

% R13 - S1/S2/S3: Complete salaried documentary evidence.
salaried_documents_complete :-
    salary_evidence_complete,
    variable_income_evidence_complete,
    fixed_allowance_evidence_complete,
    billing_evidence_complete.

% R14 - S1/S2/S3: Self-employed applicant must have business registration.
business_registration_complete :-
    answer(employment, self_employed),
    answer(business_registration, yes).

% R15 - S1/S2/S3: Supporting documents must verify business type.
business_type_evidence_complete :-
    answer(employment, self_employed),
    answer(business_type_documents, yes).

% R16 - S1/S2/S3: Six months of business current-account statements.
business_statement_evidence_complete :-
    answer(employment, self_employed),
    answer(business_statements_6_months, yes).

% R17 - S1/S2/S3: Auditor letter must confirm annual income for last 2 years.
auditor_evidence_complete :-
    answer(employment, self_employed),
    answer(auditor_letter_2_years, yes).

% R18 - S1/S2/S3: Most recent year's tax return is required.
tax_return_evidence_complete :-
    answer(employment, self_employed),
    answer(latest_tax_return, yes).

% R19 - S1/S2/S3: Most recent year's tax payment receipts are required.
tax_receipt_evidence_complete :-
    answer(employment, self_employed),
    answer(latest_tax_receipts, yes).

% R20 - S1/S2/S3: Complete self-employed documentary evidence.
self_employed_documents_complete :-
    business_registration_complete,
    business_type_evidence_complete,
    business_statement_evidence_complete,
    auditor_evidence_complete,
    tax_return_evidence_complete,
    tax_receipt_evidence_complete.

% R21 - Common published general requirements.
general_requirements_complete :-
    age_eligible,
    valid_identification.

% R22 - Platinum: general + salaried income + salaried documents.
eligible_for(platinum) :-
    general_requirements_complete,
    answer(employment, salaried),
    platinum_income_eligible,
    salaried_documents_complete.

% R23 - Signature: general + salaried income + salaried documents.
eligible_for(signature) :-
    general_requirements_complete,
    answer(employment, salaried),
    signature_income_eligible,
    salaried_documents_complete.

% R24 - Infinite: general + salaried income + salaried documents.
eligible_for(infinite) :-
    general_requirements_complete,
    answer(employment, salaried),
    infinite_income_eligible,
    salaried_documents_complete.

% R25 - Self-employed pages publish required documents but no explicit
% income threshold for the three card types. Therefore the system does
% NOT invent one; it reports whether the published document set is complete.
self_employed_published_requirements_complete :-
    general_requirements_complete,
    answer(employment, self_employed),
    self_employed_documents_complete.

% ----------------------- EVALUATION ------------------------------

evaluate :-
    answer(employment, salaried), !,
    evaluate_salaried.
evaluate :-
    answer(employment, self_employed), !,
    evaluate_self_employed.

evaluate_salaried :-
    nl,
    writeln('===================== RESULT ====================='),
    ( general_requirements_complete ->
        show_salaried_card_results
    ;
        writeln('GENERAL ELIGIBILITY REQUIREMENTS NOT SATISFIED')
    ),
    nl,
    writeln('------------------- REASONING --------------------'),
    explain_general,
    explain_salaried,
    writeln('==================================================').

show_salaried_card_results :-
    show_card_result(platinum),
    show_card_result(signature),
    show_card_result(infinite).

show_card_result(Card) :-
    ( eligible_for(Card) ->
        format('~w: PUBLISHED REQUIREMENTS SATISFIED~n', [Card])
    ;
        format('~w: PUBLISHED REQUIREMENTS NOT FULLY SATISFIED~n', [Card])
    ).

evaluate_self_employed :-
    nl,
    writeln('===================== RESULT ====================='),
    ( self_employed_published_requirements_complete ->
        writeln('SELF-EMPLOYED PUBLISHED DOCUMENT REQUIREMENTS: COMPLETE')
    ;
        writeln('SELF-EMPLOYED PUBLISHED DOCUMENT REQUIREMENTS: INCOMPLETE')
    ),
    writeln('NOTE: The cited NDB card pages do not publish a self-employed'),
    writeln('income threshold for Platinum/Signature/Infinite, so this'),
    writeln('system does not invent a final card-level eligibility decision.'),
    nl,
    writeln('------------------- REASONING --------------------'),
    explain_general,
    explain_self_employed,
    writeln('==================================================').

% ----------------------- EXPLANATION -----------------------------

explain_general :-
    explain(age_eligible,
            'Age requirement (18+) satisfied',
            'Age requirement (18+) NOT satisfied'),
    explain(valid_identification,
            'Accepted identification is available',
            'Accepted identification is NOT available').

explain_salaried :-
    explain(permanent_salaried_employee,
            'Permanent salaried employment requirement satisfied',
            'Permanent salaried employment requirement NOT satisfied'),
    explain(platinum_income_eligible,
            'Platinum gross-income threshold satisfied',
            'Platinum gross-income threshold NOT satisfied'),
    explain(signature_income_eligible,
            'Signature net-income threshold satisfied',
            'Signature net-income threshold NOT satisfied'),
    explain(infinite_income_eligible,
            'Infinite gross-income threshold satisfied',
            'Infinite gross-income threshold NOT satisfied'),
    explain(salary_evidence_complete,
            'Salary evidence available',
            'Salary evidence NOT available'),
    explain(variable_income_evidence_complete,
            'Variable-income proof available',
            'Variable-income proof NOT available'),
    explain(fixed_allowance_evidence_complete,
            'Fixed-allowance evidence condition satisfied',
            'Fixed-allowance evidence condition NOT satisfied'),
    explain(billing_evidence_complete,
            'Billing-proof condition satisfied',
            'Billing-proof condition NOT satisfied').

explain_self_employed :-
    explain(business_registration_complete,
            'Business Registration Certificate available',
            'Business Registration Certificate NOT available'),
    explain(business_type_evidence_complete,
            'Business-type supporting documents available',
            'Business-type supporting documents NOT available'),
    explain(business_statement_evidence_complete,
            'Six months of business current-account statements available',
            'Six months of business current-account statements NOT available'),
    explain(auditor_evidence_complete,
            'Two-year annual-income auditor letter available',
            'Two-year annual-income auditor letter NOT available'),
    explain(tax_return_evidence_complete,
            'Most recent tax return available',
            'Most recent tax return NOT available'),
    explain(tax_receipt_evidence_complete,
            'Most recent tax payment receipts available',
            'Most recent tax payment receipts NOT available').

explain(Goal, Pass, _) :-
    call(Goal), !,
    format('[PASS] ~w~n', [Pass]).
explain(_, _, Fail) :-
    format('[FAIL] ~w~n', [Fail]).

% ---------------- INFERENCE DEMONSTRATIONS ----------------------
% Backward chaining:
% After start. has collected answers, query goals such as:
% ?- eligible_for(platinum).
% ?- eligible_for(signature).
% ?- eligible_for(infinite).
% ?- self_employed_published_requirements_complete.

% Forward-style reporting:
forward_reasoning :-
    nl,
    writeln('CONCLUSIONS DERIVED FROM CURRENT FACTS'),
    writeln('--------------------------------------'),
    report(age_eligible, 'Applicant satisfies minimum-age requirement'),
    report(valid_identification, 'Applicant has accepted identification'),
    report(permanent_salaried_employee, 'Applicant is a permanently employed salaried employee'),
    report(platinum_income_eligible, 'Applicant satisfies Platinum salaried income threshold'),
    report(signature_income_eligible, 'Applicant satisfies Signature salaried income threshold'),
    report(infinite_income_eligible, 'Applicant satisfies Infinite salaried income threshold'),
    report(salaried_documents_complete, 'Salaried documentary requirements are complete'),
    report(self_employed_documents_complete, 'Self-employed documentary requirements are complete'),
    report(eligible_for(platinum), 'Published Platinum salaried requirements are satisfied'),
    report(eligible_for(signature), 'Published Signature salaried requirements are satisfied'),
    report(eligible_for(infinite), 'Published Infinite salaried requirements are satisfied'),
    report(self_employed_published_requirements_complete,
           'Published self-employed general/document requirements are complete').

report(Goal, Message) :-
    ( call(Goal) -> format('- ~w~n', [Message]) ; true ).
