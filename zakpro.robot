*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime

*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]  ${username}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  Open Browser
  ...      ${USERS.users['${username}'].homepage}
  ...      ${USERS.users['${username}'].browser}
  ...      alias=${username}
  Set Window Position   @{USERS.users['${username}'].position}
  Set Window Size       @{USERS.users['${username}'].size}
  Log Variables

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  ...      ${ARGUMENTS[2]} ==  id
  Switch browser   ${ARGUMENTS[0]}
  ${current_location}=   Get Location
  ${homepage}=  Set Variable  ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Run Keyword If  '${homepage}/tenders/${ARGUMENTS[2]}'=='${current_location}'  Reload Page
  Go To  ${homepage}
  Wait Until Page Contains   Makretplace   10
  sleep  1
  Input Text   id=d175:datalist:l6437  ${ARGUMENTS[1]}
  sleep  2
  ${last_note_id}=  Add pointy note   jquery=a[href^="/tenders"]   Found tender with tenderID "${ARGUMENTS[1]}"   width=200  position=bottom
  sleep  1
  Remove element   ${last_note_id}
  Click Link    jquery=a[href^="/tenders"]
  Wait Until Page Contains    ${ARGUMENTS[1]}   10
  sleep  1
  Capture Page Screenshot
