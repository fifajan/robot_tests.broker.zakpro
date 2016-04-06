*** Settings ***
Library   Selenium2Screenshots
Library   String
Library   DateTime
Library   Selenium2Library
Library   Collections
Library   zakpro_service.py


*** Variables ***
${sign_in}                                                      id=login_link
${login_sign_in}                                                id=id_login-username
${password_sign_in}                                             id=id_login-password
${locator.title}                                                xpath=//h1
${locator.description}                                          xpath=//p[contains(@class, 'qa_descr')]
${locator.minimalStep.amount}                                   xpath=//dd[contains(@class, 'qa_min_budget')]
${locator.value.amount}                                         xpath=//dd[contains(@class, 'qa_budget_pdv')]
${locator.tenderId}                                             xpath=//dd[contains(@class, 'tender-tuid')]
${locator.procuringEntity.name}                                 xpath=//dd[contains(@class, 'qa_procuring_entity')]
${locator.enquiryPeriod.startDate}                              xpath=//dd[contains(@class, 'qa_date_period_clarifications')]
${locator.enquiryPeriod.endDate}                                xpath=//dd[contains(@class, 'qa_date_period_clarifications')]
${locator.tenderPeriod.startDate}                               xpath=//dd[contains(@class, 'qa_date_submission_of_proposals')]
${locator.tenderPeriod.endDate}                                 xpath=//dd[contains(@class, 'qa_date_submission_of_proposals')]
${locator.items[0].quantity}                                    xpath=//td[contains(@class, 'qa_quantity')]/p
${locator.items[0].description}                                 xpath=//td[contains(@class, 'qa_item_name')]
${locator.items[0].deliveryLocation.latitude}                   xpath=//dd[contains(@class, 'qa_place_delivery')]
${locator.items[0].deliveryLocation.longitude}                  xpath=//dd[contains(@class, 'qa_place_delivery')]
${locator.items[0].unit.code}                                   xpath=//td[contains(@class, 'qa_quantity')]/p
${locator.items[0].unit.name}                                   xpath=//td[contains(@class, 'qa_quantity')]/p
${locator.items[0].deliveryAddress.postalCode}                  xpath=//dd[contains(@class, 'qa_address_delivery')]
${locator.items[0].deliveryAddress.countryName}                 xpath=//dd[contains(@class, 'qa_address_delivery')]
${locator.items[0].deliveryAddress.region}                      xpath=//dd[contains(@class, 'qa_address_delivery')]
${locator.items[0].deliveryAddress.locality}                    xpath=//dd[contains(@class, 'qa_address_delivery')]
${locator.items[0].deliveryAddress.streetAddress}               xpath=//dd[contains(@class, 'qa_address_delivery')]
${locator.items[0].deliveryDate.endDate}                        xpath=//dd[contains(@class, 'qa_delivery_period')]
${locator.items[0].classification.scheme}                       xpath=//dt[contains(@class, 'qa_cpv_name')]
${locator.items[0].classification.id}                           xpath=//dd[contains(@class, 'qa_cpv_classifier')]
${locator.items[0].classification.description}                  xpath=//dd[contains(@class, 'qa_cpv_classifier')]
${locator.items[0].additionalClassifications[0].scheme}         xpath=//dt[contains(@class, 'qa_dkpp_name')]
${locator.items[0].additionalClassifications[0].id}             xpath=//dd[contains(@class, 'qa_dkpp_classifier')]
${locator.items[0].additionalClassifications[0].description}    xpath=//dd[contains(@class, 'qa_dkpp_classifier')]


*** Keywords ***
Підготувати дані для оголошення тендера
  [Arguments]  ${tender_data}
  ${tender_data}=  procuringEntity_name_zakpro  ${tender_data}
  [return]   ${tender_data}

Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser   ${USERS.users['${ARGUMENTS[0]}'].homepage}   ${USERS.users['${username}'].browser}   alias=${ARGUMENTS[0]}
  Set Window Size       @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${username}' != 'Zakpro_Viewer'   Login

Login
    Click Element  ${sign_in}
    Sleep   1
    Input text      ${login_sign_in}          ${USERS.users['${username}'].login}
    Input text      ${password_sign_in}       ${USERS.users['${username}'].password}
    Click Button    name=login_submit
    Wait Until Page Contains Element   xpath=//a[@href='/accounts/mailbox/']  20

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data


  Log To Console    __VARIABLES__
  Log To Console    ${ARGUMENTS[0]}
  Log To Console    ${ARGUMENTS[1]}
  Log To Console    __END_VARIABLES__

#  ${zkp_tender_name}=      get_random_id_zakpro
#  ${title}=                Get From Dictionary         ${ARGUMENTS[1].data}   title
  ${title}=                get_random_id_zakpro
  ${description}=          Get From Dictionary         ${ARGUMENTS[1].data}   description
  ${items}=                Get From Dictionary         ${ARGUMENTS[1].data}   items
  ${item0}=                Get From List               ${items}          0
  ${descr_lot}=            Get From Dictionary         ${item0}                        description
  ${budget}=               Get From Dictionary         ${ARGUMENTS[1].data.value}         amount
  ${unit}=                 Get From Dictionary         ${items[0].unit}                name
  ${cpv_id}=               Get From Dictionary         ${items[0].classification}      id
  ${dkpp_id}=              Get From Dictionary         ${items[0].additionalClassifications[0]}      id
  ${delivery_end}=         Get From Dictionary         ${items[0].deliveryDate}        endDate
  ${postalCode}=           Get From Dictionary         ${items[0].deliveryAddress}     postalCode
  ${locality}=             Get From Dictionary         ${items[0].deliveryAddress}     locality
  ${streetAddress}=        Get From Dictionary         ${items[0].deliveryAddress}     streetAddress
  ${latitude}=             Get From Dictionary         ${items[0].deliveryLocation}    latitude
  ${longitude}=            Get From Dictionary         ${items[0].deliveryLocation}    longitude
  ${quantity}=             Get From Dictionary         ${items[0]}                     quantity
  ${step_rate}=            Get From Dictionary         ${ARGUMENTS[1].data.minimalStep}   amount
  ${dates}=                get_all_zakpro_dates
  ${end_period_adjustments}=      Get From Dictionary         ${dates}        EndPeriod
  ${start_receive_offers}=        Get From Dictionary         ${dates}        StartDate
  ${end_receive_offers}=          Get From Dictionary         ${dates}        EndDate

  Log To Console    __GOT_DATA__


  Click Element   xpath=//*[@id="default"]/div[3]/aside[1]/section/ul/li[3]/a/i[2]
  Sleep   1
  Click Element   xpath=//*[@id="default"]/div[3]/aside[1]/section/ul/li[3]/ul/li[2]/a
  Sleep   1
  Input text      xpath=//*[@id="id_title"]        ${title}
  Input text      xpath=//*[@id="id_description"]       ${description}
######
  Input text      xpath=//*[@id="id_form-0-description"]       ${descr_lot}
  Input text      xpath=//*[@id="id_form-0-quantity"]       ${quantity}
#  Input text      xpath=//*[@id="id_form-0-deliveryDate_endDate"]       ${delivery_end}
  Input text      xpath=//*[@id="id_form-0-deliveryAddress_streetAddress"]       ${streetAddress}
  Input text      xpath=//*[@id="id_form-0-deliveryAddress_locality"]       ${locality}

  Sleep    1

  Click Button    xpath=//button[@name="submit"]
  Sleep    1

  Wait Until Page Contains Element   xpath=//div[@class="tender_title text-left"]/h2      10
  Wait Until Element Contains   xpath=//div[@class="tender_title text-left"]/h2   ${title}      10

  Sleep   1

  ${tender_id}=     Get Text        xpath=//h6[@id='this_tender_id']
  Log To Console      ${tender_id}
  Sleep   1
  
  [return]    ${tender_id}


Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER}

# кабінет:
  Click Element    xpath=//*[@id="top_page"]/div[2]/div/ul/li[1]/a 

  Wait Until Page Contains Element   xpath=//a[@href='/accounts/mailbox/']  20

  Click Element   xpath=//*[@id="default"]/div[3]/aside[1]/section/ul/li[3]/a/i[2]
  Sleep   1
  Click Element   xpath=//*[@id="default"]/div[3]/aside[1]/section/ul/li[3]/ul/li[3]/a
  Sleep   1

  Wait Until Page Contains Element   xpath=//*[@id="contact_point_info"]/div[1]/div/div/div/table/tbody/tr[1]/td[5]/div[3]/a[2]    20
  Click Element   xpath=//*[@id="contact_point_info"]/div[1]/div/div/div/table/tbody/tr[1]/td[5]/div[3]/a[2]

  Sleep    4

  Input text      xpath=//*[@id="id_title"]    Тест_док

#Choose File     xpath=//input[contains(@class, 'qa_state_offer_add_field')]   ${filepath}
#Click Button    //*[@id="id_file"]
  Sleep   3
  Capture Page Screenshot

#Дочекатись синхронізації з майданчиком
#  [Arguments]  @{ARGUMENTS}
#  [Documentation]
#  ...      ${ARGUMENTS[0]} ==  username
#  ...      ${ARGUMENTS[1]} ==  tender_uaid
#
#  Log To Console __SYNC__

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid

  Log To Console    __VARIABLES__
  Log To Console    ${ARGUMENTS[0]}
  Log To Console    ${ARGUMENTS[1]}
  Log To Console    __END_VARIABLES__

  Go to   get_tender_url_zakpro    ${ARGUMENTS[1]}
  Log To Console   __TENDER_URL__
  Sleep    1

#  Input Text      id=search_text_id   ${ARGUMENTS[1]}
#  Click Button    id=search_submit
#  Sleep  2
#  CLICK ELEMENT     xpath=(//a[contains(@href, 'net/dz/')])[1]
#  Sleep  1
#  Wait Until Page Contains    ${ARGUMENTS[1]}   10
#  Sleep  1
#  Click Element   id=show_lot_info-0
#  Capture Page Screenshot

#Задати питання
#  [Arguments]  @{ARGUMENTS}
#  [Documentation]
#  ...      ${ARGUMENTS[0]} ==  username
#  ...      ${ARGUMENTS[1]} ==  tenderUaId
#  ...      ${ARGUMENTS[2]} ==  questionId
#  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
#  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description
#
#  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
#  zakpro.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
#  Sleep  1
##  Execute Javascript                  window.scroll(2500,2500)
#  Wait Until Page Contains Element    xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]    20
#  Click Element                       xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]    20
#  Wait Until Page Contains Element    name=title    20
#  Input text                          name=title                 ${title}
#  Input text                          xpath=//textarea[@name='description']           ${description}
#  Click Element                       xpath=//div[contains(@class, 'buttons')]//button[@type='submit']
#  Wait Until Page Contains            ${title}   30
#  Capture Page Screenshot


### Проверка информации с тендера
Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  ${return_value}=  run keyword  Отримати інформацію про ${ARGUMENTS[1]}
  [return]  ${return_value}

Отримати тест із поля і показати на сторінці
  [Arguments]   ${fieldname}
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [return]  ${return_value}

Отримати інформацію про title
  ${return_value}=   Отримати тест із поля і показати на сторінці   title
  [return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Отримати тест із поля і показати на сторінці   description
  [return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Отримати тест із поля і показати на сторінці  value.amount
  ${return_value}=   Remove String      ${return_value}     грн.
  ${return_value}=   Convert To Number   ${return_value.replace(' ', '').replace(',', '.')}
  [return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=   Отримати тест із поля і показати на сторінці   minimalStep.amount
  ${return_value}=    Remove String      ${return_value}     грн.
  ${return_value}=    convert to string    ${return_value.replace(' ', '')}
  [return]   ${return_value}

#Внести зміни в тендер
#  [Arguments]  @{ARGUMENTS}
#  [Documentation]
#  ...      ${ARGUMENTS[0]} ==  username
#  ...      ${ARGUMENTS[1]} ==  id

#  ...      ${ARGUMENTS[2]} ==  fieldname
#  ...      ${ARGUMENTS[3]} ==  fieldvalue
#
#  Go to   ${USERS.users['${username}'].homepage}
#  Input Text        id=search       ${ARGUMENTS[1]}
#  Click Button    xpath=//button[@type='submit']
#  Sleep   2
#  Click Element   xpath=(//td[contains(@class, 'qa_item_name')]//a)[1]
#  Sleep   2
#  Click Element     xpath=//a[contains(@href, 'state_purchase/edit')]
#  Sleep   1
#  Input text        id=title               ${title}
#  Input text        id=descr               ${description}
#  click element     id=submit_button
#  ${result_field}=   отримати текст із поля і показати на сторінці   ${ARGUMENTS[2]}
#  Should Be Equal   ${result_field}   ${ARGUMENTS[3]}
#  Go to     ${teneder_url}


Отримати інформацію про items[0].quantity
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].quantity
  ${return_value}=    Convert To Number   ${return_value.split(' ')[0]}
  [return]  ${return_value}

Отримати інформацію про items[0].unit.code
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].unit.code
  ${return_value}=   Convert To String     ${return_value.split(' ')[1]}
  ${return_value}=   Convert To String    KGM
  [return]  ${return_value}

Отримати інформацію про items[0].unit.name
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].unit.name
  ${return_value}=   convert to string     ${return_value.split(' ')[1]}
  ${return_value}=   convert_zakpro_string_to_common_string    ${return_value}
  [return]   ${return_value}

Отримати інформацію про tenderId
  ${return_value}=   Отримати тест із поля і показати на сторінці   tenderId
  [return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=   Отримати тест із поля і показати на сторінці   procuringEntity.name
  Fail   Пока не понятно как вернуть сулчайное название

Отримати інформацію про items[0].deliveryLocation.latitude
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].deliveryLocation.latitude
  ${return_value}=   convert to number   ${return_value.split(' ')[1]}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.longitude
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].deliveryLocation.longitude
  ${return_value}=   convert to number    ${return_value.split(' ')[0]}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${return_value}=    Отримати тест із поля і показати на сторінці  tenderPeriod.startDate
  ${return_value}=    convert_date_to_zakpro_tender_startdate      ${return_value}
  [return]    ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  tenderPeriod.endDate
  ${return_value}=    convert_date_to_zakpro_tender_enddate    ${return_value}
  [return]    ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  enquiryPeriod.startDate
  Fail   Данное поле отсутвует на сайте

Отримати інформацію про enquiryPeriod.endDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  enquiryPeriod.endDate
#  ${return_value}=    convert_date_to_zakpro_tender    ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].description
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].description
  [return]  ${return_value}

Отримати інформацію про items[0].classification.id
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].classification.id
  [return]  ${return_value.split(' ')[0]}

Отримати інформацію про items[0].classification.scheme
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].classification.scheme
  ${return_value}=    Remove String      ${return_value}     :
  [return]  ${return_value}

Отримати інформацію про items[0].classification.description
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].classification.description
  [return]  ${return_value.split(' ')[1]}

Отримати інформацію про items[0].additionalClassifications[0].id
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].additionalClassifications[0].id
  [return]  ${return_value.split(' ')[0]}

Отримати інформацію про items[0].additionalClassifications[0].scheme
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].additionalClassifications[0].scheme
  ${return_value}=    Remove String      ${return_value}     :
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].description
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].additionalClassifications[0].description
  [return]  ${return_value[8:]}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.countryName
  ${return_value}=   convert_zakpro_string_to_common_string    ${return_value.split(', ')[0]}
  [return]   ${return_value}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.postalCode
  [return]  ${return_value.split(', ')[1]}

Отримати інформацію про items[0].deliveryAddress.region
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.region
  ${return_value}=   convert_zakpro_string_to_common_string     ${return_value.split(', ')[2]}
  [return]   ${return_value}

Отримати інформацію про items[0].deliveryAddress.locality
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.locality
  [return]  ${return_value.split(', ')[3]}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.streetAddress
  [return]  ${return_value.split(', ')[4]}

## Період доставки:
Отримати інформацію про items[0].deliveryDate.endDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].deliveryDate.endDate
  ${return_value}=    convert_date_to_zakpro_tender      ${return_value.split(u'до ')[1]}
  [return]  ${return_value}

## не сделано
Отримати інформацію про questions[0].title
  ${return_value}=  Отримати тест із поля і показати на сторінці   questions[0].title
  [return]  ${return_value}

Отримати інформацію про questions[0].description
  ${return_value}=   Отримати тест із поля і показати на сторінці   questions[0].description
  [return]  ${return_value}

Отримати інформацію про questions[0].date
  ${return_value}=   Отримати тест із поля і показати на сторінці   questions[0].date

  [return]  ${return_value}

Отримати інформацію про questions[0].answer
  ${return_value}=   Отримати тест із поля і показати на сторінці   questions[0].answer
  [return]  ${return_value}
