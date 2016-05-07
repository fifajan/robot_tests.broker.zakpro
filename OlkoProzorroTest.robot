*** Settings ***
Suite Setup       Start Selenium Server
Suite Teardown    Stop Selenium Server
Test Setup        Begin Test
Test Teardown     Close All Browsers
Library           BuiltIn
Library           SeleniumLibrary

*** Test Cases ***
test for open site
    Find Element By ID
    Page Should Contain Element    xpath=.//*[@id='result']

show title of tender
    Find Element By ID
    Click Element    xpath=.//*[@id='result']/div[2]/div/div/div/div[1]/a/span
    Page Should Contain Element    class=tender--head--title col-sm-9

show date of begin
    Find Element By ID
    Click Element    xpath=.//*[@id='result']/div[2]/div/div/div/div[1]/a/span
    Page Should Contain Element    xpath=/html/body/div[2]/div[2]/div[1]/div/div[1]

show date of end
    Find Element By ID
    Click Element    xpath=.//*[@id='result']/div[2]/div/div/div/div[1]/a/span
    Page Should Contain Element    xpath=html/body/div[2]/div[2]/div[2]/div/div/div/div/div[2]/div/table/tbody/tr[2]/td[2]

*** Keywords ***
Begin Test
    Open Browser    http://dev.prozorro.org/    googlechrome
    Set Selenium Speed    2 seconds
    Click Element    name=tender-v2

Find Element By ID
    Click Element    xpath=.//*[@id='buttons']/button[4]
    Input Text    xpath=.//*[@id='blocks']/div/input    UA-2016-05-05-000016
    Focus    xpath=.//*[@id='blocks']/div/input
    Press Key Native    39
