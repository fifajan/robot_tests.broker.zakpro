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
${locator.title}                                                xpath=//div[@class="tender_title text-left"]/h2
${locator.description}                                          xpath=//div[@class="tender_description"]/h5
${locator.minimalStep.amount}                                   xpath=//*[@id="info"]/div/dl/dd[2]
${locator.value.amount}                                         xpath=//*[@id="info"]/div/dl/dd[1]
${locator.currency}                                             xpath=//*[@id="info"]/div/dl/dd[1]
${locator.tax}                                                  xpath=//*[@id="info"]/div/dl/dd[1]
${locator.tenderId}                                             xpath=//*[@id="info"]/div/dl/dd[4]
${locator.procuringEntity.name}                                 xpath=//*[@id="content_inner"]/article/div[2]/div[1]/div[5]/div/dl[1]/dd[2]
${locator.legalName}                                            xpath=//*[@id="content_inner"]/article/div[2]/div[1]/div[5]/div/dl[1]/dd[1]
${locator.enquiryPeriod.startDate}                              xpath=//*[@id="dates"]/div/dl/dd[1]
${locator.tenderPeriod.startDate}                               xpath=//*[@id="dates"]/div/dl/dd[2]
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
  [Documentation]  Це слово використовується в майданчиків, тому потрібно, щоб воно було і тут
  [Arguments]  ${username}  ${tender_data}
  ${tender_data}=  adapt_zakpro_data  ${tender_data}
  Run Keyword And Return  adapt_unit_names  ${tender_data}

Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser
  ...      ${USERS.users['${ARGUMENTS[0]}'].homepage}
  ...      ${USERS.users['${ARGUMENTS[0]}'].browser}
  ...      alias=${ARGUMENTS[0]}
  Set Window Size       @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If                     '${ARGUMENTS[0]}' != 'zakpro_Viewer'   Login   ${ARGUMENTS[0]}


Login
  [Arguments]  @{ARGUMENTS}
  Click Element  ${sign_in}
  Sleep   1
  Input text      ${login_sign_in}          ${USERS.users['${ARGUMENTS[0]}'].login}
  Input text      ${password_sign_in}       ${USERS.users['${ARGUMENTS[0]}'].password}
  Click Button    name=login_submit
  Wait Until Page Contains Element   xpath=//a[@href='/accounts/mailbox/']  20


###############################################################################################################
######################################    СТВОРЕННЯ ТЕНДЕРУ    ################################################
###############################################################################################################

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  ${username}=            Set Variable   ${ARGUMENTS[0]}
  Set To Dictionary  ${USERS.users['${tender_owner}']}  tender_data  ${ARGUMENTS[1]}

  ${title}=                Get From Dictionary         ${ARGUMENTS[1].data}   title
  ${proc_name}=            Get From Dictionary         ${ARGUMENTS[1].data.procuringEntity}   name
#  ${title}=                get_random_id_zakpro
  ${description}=          Get From Dictionary         ${ARGUMENTS[1].data}   description
  ${items}=                Get From Dictionary         ${ARGUMENTS[1].data}   items
  ${item0}=                Get From List               ${items}          0
  ${descr_lot}=            Get From Dictionary         ${item0}                        description
  ${budget}=               Get From Dictionary         ${ARGUMENTS[1].data.value}         amount
  ${unit}=                 Get From Dictionary         ${items[0].unit}                name
  ${cpv_id}=               Get From Dictionary         ${items[0].classification}      id
  ${class_descr}=          Get From Dictionary         ${items[0].classification}  description   
  ${dkpp_id}=              Get From Dictionary         ${items[0].additionalClassifications[0]}      id
  ${dkpp_descr}=              Get From Dictionary         ${items[0].additionalClassifications[0]}      description
  ${delivery_end}=         Get From Dictionary         ${items[0].deliveryDate}        endDate
  ${postalCode}=           Get From Dictionary         ${items[0].deliveryAddress}     postalCode
  ${locality}=             Get From Dictionary         ${items[0].deliveryAddress}     locality
  ${region}=             Get From Dictionary         ${items[0].deliveryAddress}     region
  ${streetAddress}=        Get From Dictionary         ${items[0].deliveryAddress}     streetAddress
  ${latitude}=             Get From Dictionary         ${items[0].deliveryLocation}    latitude
  ${longitude}=            Get From Dictionary         ${items[0].deliveryLocation}    longitude
  ${quantity}=             Get From Dictionary         ${items[0]}                     quantity
  ${step_rate}=            Get From Dictionary         ${ARGUMENTS[1].data.minimalStep}   amount
  ${dates}=                get_all_zakpro_dates
  ${end_period_adjustments}=      Get From Dictionary         ${dates}        EndPeriod
  ${start_receive_offers}=        Get From Dictionary         ${dates}        StartDate
  ${end_receive_offers}=          Get From Dictionary         ${dates}        EndDate


  Click Element   xpath=//*[@id="default"]/div[3]/aside[1]/section/ul/li[4]/a
  Sleep   1
  Click Element   xpath=//*[@id="default"]/div[3]/aside[1]/section/ul/li[4]/ul/li[1]/a
  Sleep   1
  Input text      xpath=//*[@id="id_title"]        ${title}
  Input text      xpath=//*[@id="id_description"]       ${description}
######
  Input text      xpath=//*[@id="id_form-0-description"]       ${descr_lot}
  Input text      xpath=//*[@id="id_form-0-quantity"]       ${quantity}
#  Input text      xpath=//*[@id="id_form-0-deliveryDate_endDate"]       ${delivery_end}

  Sleep  4
  Input text      xpath=//*[@id="id_enquiryPeriod_endDate"]     ${end_period_adjustments}
  Input text      xpath=//*[@id="id_tenderPeriod_startDate"]    ${start_receive_offers}
  Input text      xpath=//*[@id="id_tenderPeriod_endDate"]    ${end_receive_offers}

  Sleep  4

  Input text      xpath=//*[@id="id_form-0-deliveryAddress_streetAddress"]       ${streetAddress}
  Input text      xpath=//*[@id="id_form-0-deliveryAddress_locality"]       ${locality}
  Log To Console   __BEFORE_FLOAT__
  ${budget}=     Convert To String  ${budget}
  Input text     xpath=//*[@id="id_value_amount"]    ${budget}
  Input text     xpath=//*[@id="id_procuringEntity_name"]   ${proc_name}
  ${step_rate}=     Convert To String  ${step_rate}
  Input text     xpath=//*[@id="id_minimalStep_amount"]   ${step_rate}
  Log To Console   __AFTER_FLOAT__
  Input text     xpath=//*[@id="id_form-0-deliveryAddress_postalCode"]   ${postalCode}
  Input text     xpath=//*[@id="id_form-0-classification_description"]   ${class_descr}
  Input text      xpath=//*[@id="id_form-0-deliveryAddress_region"]    ${region}
  Sleep    1

#  Input text      xpath=//*[@id="id_form-0-deliveryDate_endDate"]    ${delivery_end}
  Input text      xpath=//*[@id="id_form-0-unit_name"]    ${unit}
  Sleep     1

  Input text      xpath=//*[@id="id_form-0-LIST_additionalClassifications0of1_description"]      ${dkpp_descr}

  Sleep    1


  Click Button    xpath=//button[@name="submit"]
  Sleep    1

  Wait Until Page Contains Element   xpath=//div[@class="tender_title text-left"]/h2      10
  Wait Until Element Contains   xpath=//div[@class="tender_title text-left"]/h2   ${title}      10

  Sleep   1

  ${tender_id}=     Get Text        xpath=//*[@id="info"]/div/dl/dd[4]

  Log To Console      ${tender_id}
  Sleep   5

  [return]    ${tender_id}


#############################################################################################################


Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER}
# кабінет:
  Click Element    xpath=//*[@id="top_page"]/div[2]/div/ul/li[1]/a 

  Wait Until Page Contains Element   xpath=//a[@href='/accounts/mailbox/']  20

  Click Element   xpath=//*[@id="default"]/div[3]/aside[1]/section/ul/li[4]/a/i[2]
  Sleep   1
  Click Element   xpath=//*[@id="default"]/div[3]/aside[1]/section/ul/li[4]/ul/li[3]/a
  Sleep   1

  Wait Until Page Contains Element   xpath=//*[@id="contact_point_info"]/div[1]/div/div/div/table/tbody/tr[1]/td[1]/div/button    20
  Click Element  xpath=//*[@id="contact_point_info"]/div[1]/div/div/div/table/tbody/tr[1]/td[1]/div/button 
  Sleep   1
  Click Element  xpath=//*[@id="contact_point_info"]/div[1]/div/div/div/table/tbody/tr[1]/td[1]/div/ul/li[3]/a

  Sleep    4
#  Log To Console   __TRIGGER_SEARCH_SYNC__
#  ${DONE} =       trigger_search_sync_zakpro
#  Log To Console   ${DONE}


  Input text      xpath=//*[@id="id_title"]    Тест_док

  Choose File     xpath=//input[@name='file']   ${ARGUMENTS[1]}
#####################################################################
#Click Button    //*[@id="id_file"]
#  Log To Console   __SLEEPING_FOR_1150_SECONDS__SEARCH_SYNC__
#  Sleep   250
#  Log To Console   __SLEEPING___900_SECONDS__LEFT__
#  Sleep   250
#  Log To Console   __SLEEPING___650_SECONDS__LEFT__
#  Sleep   250
#  Log To Console   __SLEEPING___400_SECONDS__LEFT__
#  Sleep   250
#  Log To Console   __SLEEPING___150_SECONDS__LEFT__
#  Sleep   100
#  Log To Console   __SLEEPING__50_SECONDS__LEFT__
#  Sleep   40
#  Log To Console   __SLEEPING__10_SECONDS__LEFT__
#  Sleep   10
#  Capture Page Screenshot
#####################################################################

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  Switch browser   ${ARGUMENTS[0]}

#  Log To Console  ${HP_URL}
  Log To Console   __IN_TENDER_SEARCH__

  Go To  ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Wait Until Page Contains Element            xpath=//*[@id="id_q"]    10

  Input text                          xpath=//*[@id="id_q"]  ${ARGUMENTS[1]}
  Sleep  1
  Click Element                       xpath=//*[@id="default"]/div[2]/div[1]/form[1]/button
  Wait Until Page Contains Element    xpath=//*[@id="default"]/div[2]/div[2]/div/div/section/ul/li/article/div/div[1]/a     20
  Click Element                       xpath=//*[@id="default"]/div[2]/div[2]/div/div/section/ul/li/article/div/div[1]/a 

  Wait Until Page Contains Element    xpath=//*[@id="info"]/div/dl/dd[4]    20
  Log To Console    __SEARCHING_ID_ON_PAGE__
  Log To Console    ${ARGUMENTS[1]}
  Wait Until Element Contains         xpath=//*[@id="info"]/div/dl/dd[4]   ${ARGUMENTS[1]}    20
  Log To Console    __FOUND__

  Отримати текст із поля і показати на сторінці    title

  Sleep    2
#  ${ltcons}=    Get Text    //*[@id="info"]/div/dl/comment()
#  xpath=//*[@id="info"]/div/dl/dd[1]/text()[1]
#xpath=//*[@id="default"]/div[2]/div/div[3]/h5
#xpath=//*[@id="content_inner"]/article/div[2]/div[3]/div/dl/dd[2]
#Log To Console   ${ltcons}
  Sleep    10

  Capture Page Screenshot
  Sleep    2
  Log To Console    __DONE__


###############################################################################################################
###########################################    ПИТАННЯ    #####################################################
###############################################################################################################

Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderUaId
  ...      ${ARGUMENTS[2]} ==  questionId
  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  zakpro.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  sleep  1
  Execute Javascript                  window.scroll(2500,2500)
  Wait Until Page Contains Element    xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]    20
  Click Element 4                     xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
  Wait Until Page Contains Element    name=title    20
  Input text                          name=title                 ${title}
  Input text                          xpath=//textarea[@name='description']           ${description}
  Click Element                       xpath=//div[contains(@class, 'buttons')]//button[@type='submit']
  Wait Until Page Contains            ${title}   30
  Capture Page Screenshot
  Log Many   ${ARGUMENTS[2]}
  [return]   ${ARGUMENTS[2]}

Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data

  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer
  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}

  zakpro.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Execute Javascript                  window.scroll(1500,1500)
  Wait Until Page Contains Element    xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]    20
  Click Element                       xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
  Sleep   1
  Wait Until Page Contains Element    xpath=//textarea[@name='answer']    20
  Input text                          xpath=//textarea[@name='answer']            ${answer}
  Click Element                       xpath=//form[@class='answer_form']//button
  Sleep   2
  Reload Page
  Wait Until Page Contains            ${answer}   30
  Capture Page Screenshot

################################################################################################################


Подати скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId
  ...      ${ARGUMENTS[2]} = complaintsId
  ${complaint}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=      Get From Dictionary  ${ARGUMENTS[2].data}  description

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  zakpro.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  sleep  1
  Execute Javascript                 window.scroll(1500,1500)
  Click Element                      xpath=//a[@class='reverse openCPart'][span[text()='Скарги']]
  Wait Until Page Contains Element   name=title    20
  Input text                         name=title                 ${complaint}
  Input text                         xpath=//textarea[@name='description']           ${description}
  Click Element                      xpath=//div[contains(@class, 'buttons')]//button[@type='submit']
  Wait Until Page Contains           ${complaint}   30
  Capture Page Screenshot

Порівняти скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId
  ...      ${ARGUMENTS[2]} = complaintsData
  ${complaint}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=      Get From Dictionary  ${ARGUMENTS[2].data}  description

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  zakpro.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  sleep  1
  Execute Javascript                 window.scroll(1500,1500)
  Click Element                      xpath=//a[@class='reverse openCPart'][span[text()='Скарги']]
  Wait Until Page Contains           ${complaint}   30
  Capture Page Screenshot

Внести зміни в тендер
  #  Тест написано для уже існуючого тендеру, що знаходиться у чернетках користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderID
  ...      ${ARGUMENTS[2]} = description


  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  zakpro.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}  
#  Execute Javascript                 $(".topFixed").remove();
#  Click Element                      xpath=//a[@class='reverse'][./text()='Мої закупівлі']
#  Wait Until Page Contains Element   xpath=//a[@class='reverse'][./text()='Чернетки']   30
#  Click Element                      xpath=//a[@class='reverse'][./text()='Чернетки']
#  Wait Until Page Contains Element   xpath=//a[@class='reverse tenderLink']    30
#  Click Element                      xpath=//a[@class='reverse tenderLink']
#  sleep  1
#  Click Element                      xpath=//a[@class='button save'][./text()='Редагувати']
  sleep  1
#  Input text                         name=data[description]   ${ARGUMENTS[2]}
  sleep  1
#  Click Element                      xpath=//button[@value='save']
  Wait Until Page Contains           ${ARGUMENTS[2]}   30
  Capture Page Screenshot

Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = tenderUaId

  Log To Console  __IN_ZAKPRO__
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  zakpro.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Reload Page


Отримати інформацію із запитання
  [Arguments]   @{ARGUMENTS}
  Log Many    @{ARGUMENTS}
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[1]}


Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  ${item_index}=        Get Substring    ${ARGUMENTS[1]}    6    7
  Set Suite Variable    ${item_index}    ${item_index}
  Switch browser        ${ARGUMENTS[0]}
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[1]}

Отримати текст із поля і показати на сторінці
  [Arguments]   ${fieldname}
  sleep  1
  ${return_value}=    Get Text  ${locator.${fieldname}}
  [return]  ${return_value}

Отримати інформацію про title
  ${title}=   Отримати текст із поля і показати на сторінці   title
  [return]  ${title}

Отримати інформацію про description
  ${description}=   Отримати текст із поля і показати на сторінці   description
  [return]  ${description}


Отримати інформацію про tenderId
  ${tenderId}=   Отримати текст із поля і показати на сторінці   tenderId
  [return]  ${tenderId}

Отримати інформацію про value.amount
  ${valueAmount}=   Отримати текст із поля і показати на сторінці   value.amount
  Log To Console    __VALUE_AMOUNT__
  Log To Console    ${valueAmount}
  ${valueAmount}=   Convert To Number   ${valueAmount.strip().split(' ')[0].replace(',', '.')}
  [return]  ${valueAmount}

Отримати інформацію про value.currency
  ${currency}=   Отримати текст із поля і показати на сторінці   value.amount
  [return]  ${currency.strip().split(' ')[1]}

Отримати інформацію про value.valueAddedTaxIncluded
  ${tax}=   Отримати текст із поля і показати на сторінці   value.amount
  ${tax}=   Convert To Boolean   ${tax.strip().split(' ')[2].find(u'без')}
  [return]  ${tax}

Отримати інформацію про minimalStep.amount
  Click Element      xpath=//*[@id="content_inner"]/article/div[2]/div[1]/div[4]/div/ul/li[1]/a
  Sleep  2

  ${minimalStepAmount}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${minimalStepAmount}=   Convert To Number   ${minimalStepAmount.split(' ')[0]}
  [return]  ${minimalStepAmount}

Отримати інформацію про enquiryPeriod.startDate
  Click Element     xpath=//*[@id="content_inner"]/article/div[2]/div[1]/div[4]/div/ul/li[3]/a
  Sleep   2

  ${enquiryPeriodStartDate}=   Отримати текст із поля і показати на сторінці   enquiryPeriod.startDate
  ${enquiryPeriodStartDate}=   conv_dates_zakpro   ${enquiryPeriodStartDate}
  
#  ${enquiryPeriodStartDate}=   subtract_from_time    ${enquiryPeriodStartDate}   11   0
  [return]  ${enquiryPeriodStartDate[0]}

Отримати інформацію про tenderPeriod.startDate
  ${tenderPeriodStartDate}=   Отримати текст із поля і показати на сторінці   tenderPeriod.startDate
  Log To Console   __tenderPeriod_startDate__
  Log To Console   ${tenderPeriodStartDate}
  ${tenderPeriodStartDate}=   conv_dates_zakpro   ${tenderPeriodStartDate}
#  ${tenderPeriodStartDate}=   subtract_from_time    ${tenderPeriodStartDate}   11   0
  [return]  ${tenderPeriodStartDate[0]}

Отримати інформацію про enquiryPeriod.endDate
  ${enquiryPeriodEndDate}=   Отримати текст із поля і показати на сторінці   enquiryPeriod.startDate
  ${enquiryPeriodEndDate}=   conv_dates_zakpro   ${enquiryPeriodEndDate}
#  ${enquiryPeriodEndDate}=   subtract_from_time   ${enquiryPeriodEndDate}   6   5
  [return]  ${enquiryPeriodEndDate[1]}

Отримати інформацію про tenderPeriod.endDate
  ${tenderPeriodEndDate}=   Отримати текст із поля і показати на сторінці   tenderPeriod.startDate
  ${tenderPeriodEndDate}=   conv_dates_zakpro   ${tenderPeriodEndDate}
#  ${tenderPeriodEndDate}=   subtract_from_time    ${tenderPeriodEndDate}   11   0
  [return]  ${tenderPeriodEndDate[1]}

Отримати інформацію про items[${item_index}].deliveryAddress.countryName
  ${countryName}=   Отримати текст із поля і показати на сторінці   items.deliveryAddress.countryName
  [return]  ${countryName.split(',')[1].strip()}

Отримати інформацію про items[${item_index}].classification.scheme
  ${classificationScheme}=   Отримати текст із поля і показати на сторінці   items.classification.scheme
  [return]  ${classificationScheme.split(' ')[1]}

Отримати інформацію про items[${item_index}].additionalClassifications[0].scheme
  ${additionalClassificationsScheme}=   Отримати текст із поля і показати на сторінці   items.additionalClassifications[0].scheme
  ${additionalClassificationsScheme}=   convert_string_from_dict_zakpro                   ${additionalClassificationsScheme.split(' ')[1]}
  [return]  ${additionalClassificationsScheme}

Отримати інформацію про questions[0].title
  #sleep  3
  #Click Element       xpath=//a[@class='reverse tenderLink']
  sleep  3
  Click Element        xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
  ${questionsTitle}=   Отримати текст із поля і показати на сторінці    questions[0].title
  ${questionsTitle}=   Convert To Lowercase   ${questionsTitle}
  ${questionsTitle}=   Set Variable   ${questionsTitle.split(' (')[0]}
  [return]  ${questionsTitle.capitalize().split('.')[0] + '.'}

Отримати інформацію про questions[0].description
  ${questionsDescription}=   Отримати текст із поля і показати на сторінці   questions[0].description
  [return]  ${questionsDescription}

Отримати інформацію про questions[0].date
  ${questionsDate}=   Отримати текст із поля і показати на сторінці   questions[0].date
  log  ${questionsDate}
  [return]  ${questionsDate}

Отримати інформацію про questions[0].answer
#  sleep  2
#  Click Element                       xpath=//a[@class='reverse tenderLink']
  sleep  2
  Click Element         xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
  ${questionsAnswer}=   Отримати текст із поля і показати на сторінці   questions[0].answer
  [return]  ${questionsAnswer}

Отримати інформацію про items[${item_index}].deliveryDate.endDate
  Click Element     xpath=//*[@id="content_inner"]/article/div[2]/div[1]/div[1]/div/table/tbody/tr[1]/td[4]/a
  Sleep   2

  ${deliveryDateEndDate}=   Отримати текст із поля і показати на сторінці   items[${item_index}].deliveryDate.endDate
  ${deliveryDateEndDate}=   conv_dates_zakpro   ${deliveryDateEndDate}
  [return]  ${deliveryDateEndDate[1]}

Отримати інформацію про items[${item_index}].classification.id
  ${classificationId}=   Отримати текст із поля і показати на сторінці   items.classification.id
  [return]  ${classificationId}

Отримати інформацію про items[${item_index}].classification.description
  ${classificationDescription}=   Отримати текст із поля і показати на сторінці   items.classification.description
  ${classificationDescription}=   convert_string_from_dict_zakpro                    ${classificationDescription}
#  Run Keyword And Return If  '${classificationDescription}' == 'Картонки'    Convert To String  Cartons
  [return]  ${classificationDescription}

Отримати інформацію про items[${item_index}].additionalClassifications[0].id
  ${additionalClassificationsId}=   Отримати текст із поля і показати на сторінці     items.additionalClassifications[0].id
  [return]  ${additionalClassificationsId}

Отримати інформацію про items[${item_index}].additionalClassifications[0].description
  ${additionalClassificationsDescription}=   Отримати текст із поля і показати на сторінці     items.additionalClassifications[0].description
#  ${additionalClassificationsDescription}=   Convert To Lowercase   ${additionalClassificationsDescription}
  [return]  ${additionalClassificationsDescription}

Отримати інформацію про items[${item_index}].quantity
  ${itemsQuantity}=   Отримати текст із поля і показати на сторінці     items.quantity
  ${itemsQuantity}=   Convert To Integer                                ${itemsQuantity}
  [return]  ${itemsQuantity}

Отримати інформацію про items[${item_index}].unit.code
#  ${unitCode}=   Отримати текст із поля і показати на сторінці     items.unit.code
#  Run Keyword And Return If  '${unitCode}'== 'кг'   Convert To String  KGM
#  [return]  ${unitCode}
   Log       | Код одиниці вимірювання не виводиться на ZakPro      console=yes

Отримати інформацію про procuringEntity.name
  ${legalName}=   Отримати текст із поля і показати на сторінці   procuringEntity.name
  [return]  ${legalName}

Отримати інформацію про items[${item_index}].deliveryLocation.longitude
  Log       | Viewer can't see this information on ZakPro        console=yes

Отримати інформацію про items[${item_index}].deliveryLocation.latitude
  Log       | Viewer can't see this information on ZakPro        console=yes

Отримати інформацію про items[${item_index}].deliveryAddress.postalCode
  ${postalCode}=   Отримати текст із поля і показати на сторінці   items.deliveryAddress.postalCode
  [return]  ${postalCode.split(',')[0]}

Отримати інформацію про items[${item_index}].deliveryAddress.locality
  ${locality}=   Отримати текст із поля і показати на сторінці   items.deliveryAddress.locality
  [return]  ${locality.split(',')[3].strip()}

Отримати інформацію про items[${item_index}].deliveryAddress.streetAddress
  ${streetAddress}=   Отримати текст із поля і показати на сторінці   items.deliveryAddress.streetAddress
  ${streetAddress}=   Convert To String                               ${streetAddress}
  [return]  ${streetAddress.split(',')[4].strip()}

Отримати інформацію про items[${item_index}].deliveryAddress.region
  ${region}=    Отримати текст із поля і показати на сторінці   items.deliveryAddress.region
  ${region}=    Set Variable                                    ${region.split(',')[2].strip()}  
  ${region}=    convert_string_from_dict_zakpro                    ${region}
  [return]    ${region}

Отримати інформацію про items[${item_index}].unit.name
  ${unitName}=   Отримати текст із поля і показати на сторінці     items.unit.name
  ${unitName}=   convert_string_from_dict_zakpro    ${unitName}
  [return]  ${unitName}

Отримати інформацію про items[${item_index:[^las]+}].description
  ${itemsDescription}=   Отримати текст із поля і показати на сторінці     items.Description
  [return]  ${itemsDescription}

Отримати інформацію про bids
  ${bids}=    Отримати текст із поля і показати на сторінці   bids
  [return]  ${bids}

Отримати інформацію про procurementMethodType
  ${procurementMethodType}=   Отримати текст із поля і показати на сторінці    procurementMethodType
  ${procurementMethodType}=   convert_string_from_dict_zakpro                     ${procurementMethodType}
  [return]  ${procurementMethodType}

Отримати інформацію про cancellations[0].status
  ${cancellations[0].status}=   Get Element Attribute    xpath=//div[@id="tenderStatus"]/div[4]@class
  ${cancellations[0].status}=   Set Variable If   '${cancellations[0].status}' == 'statusItem active'    active    pending
  [return]  ${cancellations[0].status}

Отримати інформацію про cancellations[0].reason
  Run Keyword And Ignore Error   Click Element   xpath=//a[@class="cancelInfo"]
  ${cancellations[0].reason}=   Отримати текст із поля і показати на сторінці   cancellations[0].reason
  [return]  ${cancellations[0].reason}

Отримати інформацію про cancellations[0].documents[0].description
  Log       | Description документу Cancellation є необов’язковим і не виводиться на ДЗО      console=yes
  

Отримати інформацію про cancellations[0].documents[0].title
  Run Keyword And Ignore Error   Click Element   xpath=//a[@class="cancelInfo"]
  ${cancellations[0].documents[0].title}=   Отримати текст із поля і показати на сторінці   cancellations[0].documents[0].title
  [return]  ${cancellations[0].documents[0].title}



Подати цінову пропозицію
  [Arguments]    @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  ${bid}=    Get From Dictionary          ${ARGUMENTS[2].data.value}              amount
  zakpro.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}                         ${ARGUMENTS[1]}
  Run keyword if   '${TEST NAME}' != 'Неможливість подати цінову пропозицію до початку періоду подачі пропозицій першим учасником'
#  ...    Wait Until Keyword Succeeds    10 x   60 s    
#  ...    Дочекатися синхронізації для періоду подачі пропозицій
#  Input Text                              name=data[value][amount]                ${bid}
#  
#  Run keyword if     "${mode}" == "openua"    Run Keywords
#  ...    Click Element                    xpath=//input[@name='data[selfQualified]']/following-sibling::span
#  ...    AND
#  ...    Click Element                    xpath=//input[@name='data[selfEligible]']/following-sibling::span
#
#  Click Button                            name=do
#  Sleep   1
#  Click Element                           xpath=//a[./text()= 'Закрити']
#  Sleep   1
#  Click Button                            name=pay
#  Sleep   10
#  Click Element                           xpath=//a[./text()= 'OK']
  [return]  ${Arguments[2]}

########## Видалити після встановлення коректних часових проміжків для періодів #######################
Дочекатися синхронізації для періоду подачі пропозицій
  Reload Page
#  Wait Until Page Contains    Ваша пропозиція

Дочекатися синхронізації для періоду аукціон
  Reload Page
#  Wait Until Page Contains    Кваліфікація учасників
########################################################################################################

Змінити цінову пропозицію
  [Arguments]    @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${amount}
  ...      ${ARGUMENTS[3]} ==  ${bid}
  Log Many    @{ARGUMENTS}
  zakpro.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}                              ${ARGUMENTS[1]}
#  Run keyword if   '${TEST NAME}' == 'Неможливість змінити цінову пропозицію до 50000 після закінчення прийому пропозицій'
#  ...    Wait Until Keyword Succeeds    10 x   60 s    
#  ...    Дочекатися синхронізації для періоду аукціон
#  Wait Until Page Contains                Ваша пропозиція                              10
  Sleep  1
#  Click Element                           xpath=//a[@class='button save bidToEdit']
#  Sleep  1
#  Input text                              name=data[value][amount]                     ${ARGUMENTS[3]}
#  Click Element                           xpath=//button[@value='save']
  Sleep  2
#  Run Keyword And Ignore Error   Wait Until Page Contains                Підтвердіть зміни в пропозиції
#  Run Keyword And Ignore Error   Input Text                              xpath=//div[2]/form/table/tbody/tr[1]/td[2]/div/input    203986723
#  Run Keyword And Ignore Error   Click Element                           xpath=//button[./text()='Надіслати']
#  [return]  ${Arguments[2]}

Скасувати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  bid_number
  zakpro.Пошук тендера по ідентифікатору     ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
#  Wait Until Page Contains                Ваша пропозиція                              10
#  Click Element                           xpath=//a[@class='button save bidToEdit']
#  Wait Until Page Contains                Відкликати пропозицію                        10
#  Click Element                           xpath=//button[@value='unbid']
  Sleep   1
#  Click Element                           xpath=//a[@class='jBtn green']
  Sleep   2
#  Wait Until Page Contains                Підтвердіть зміни в пропозиції
#  Input Text                              xpath=//div[2]/form/table/tbody/tr[1]/td[2]/div/input    203986723
#  Click Element                           xpath=//button[./text()='Надіслати']
#  Wait Until Page Contains                Вашу пропозицію відкликано    30
#  Click Element                           xpath=//a[./text()= 'Закрити']
  [return]  ${Arguments[1]}


Отримати пропозицію
  [Arguments]  ${username}  ${tenderId}
#  zakpro.Пошук тендера по ідентифікатору     ${username}    ${tenderId}
  ${resp}=     Run Keyword And Return Status    Element Should Be Visible   xpath=//body
  Log   ${resp}
  ${status}=   Set Variable If     "${resp}" == "True"    invalid   active
  ${data}=     Create Dictionary   status=${status}
  ${bid}=      Create Dictionary   data=${data}
  Log Many     ${bid}
  Capture Page Screenshot
  [return]  ${bid}



Завантажити документ в ставку
  [Arguments]  ${username}  ${filePath}  ${tenderId}
  zakpro.Пошук тендера по ідентифікатору     ${username}    ${tenderId}
#  Wait Until Page Contains                Ваша пропозиція                               10
#  Click Element                           xpath=//a[@class='button save bidToEdit']
#  Execute Javascript                      $("body > div").removeAttr("style");
  Log   ${filePath}
#  Choose File                             xpath=/html/body/div[1]/form/input            ${filePath}
#  Click Element                           xpath=//button[@value='save']


Змінити документ в ставці
  [Arguments]   ${username}  ${filepath}  ${bidid}  ${docid}
#  Execute Javascript                      $(".topFixed").remove();
  Sleep   1
#  Click Element                           xpath=//a[@class='button save bidToEdit']
#  Execute Javascript                      $("body > div").removeAttr("style");
#  Log   ${filePath}
#  Choose File                             xpath=//input[@title='Завантажити оновлену версію']    ${filePath}
#  Click Element                           xpath=//button[@value='save']
  Log  __DONE__

Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tenderId}
  Sleep   5
#  zakpro.Пошук тендера по ідентифікатору   ${username}    ${tenderId}
  ${url}=                               Get Element Attribute                     xpath=//div[1]@class
  [return]  ${url}

Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tenderId}
#  zakpro.Пошук тендера по ідентифікатору   ${username}    ${tenderId}
#  Click Element                         xpath=//a[@class="reverse getAuctionUrl"]
  Sleep   3
  ${url}=                               Get Element Attribute                     xpath=//div[1]@class
  [return]  ${url}


Створити вимогу
  [Arguments]  ${username}  ${tenderId}  ${claim}
#  Log Many   ${claim}
  ${claimTitle}=          Get From Dictionary    ${claim.data}    title
  ${claimDescription}=    Get From Dictionary    ${claim.data}    description
  zakpro.Пошук тендера по ідентифікатору   ${username}    ${tenderId}
  Sleep  1
#  Execute Javascript          $(".enquiries").removeClass("floatMenu"); $("body > div").removeAttr("style");
#  Click Element                         xpath=//a[@class='reverse openCPart' ]/span[contains(text(),'Скарги')]
#  Wait Until Page Contains Element      xpath=//a[@class='addComplaint']      10
#  Click Element                         xpath=//a[@class='addComplaint']
#  Click Element                         ${locator.ModalOk}
#  Input text                  xpath=//form[@name='tender_complaint']//input[@name='title']    ${claimTitle}
#  Input text                  xpath=//form[@name='tender_complaint']//textarea[@name='description']    ${claimDescription}
#  Execute Javascript          $('#jAlertBack').remove();
#  Click Element               xpath=//form[@name='tender_complaint']//button[@class='bidAction']
#  Sleep   5
#  Execute Javascript          $('#modal').children('.back').click();
#  Wait Until Page Contains    ${claimTitle}     10
  ${claimID}=    Get Text     xpath=//div[1]
  [return]  ${claimID}

Скасувати вимогу
  [Arguments]  @{ARGUMENTS}
  Log Many   @{ARGUMENTS}
  zakpro.Пошук тендера по ідентифікатору   ${username}    ${tenderId}
#  Click Element                         xpath=//a[@class='reverse openCPart'][span[text()='Скарги']]
#  Click Element                         xpath=//a[@data-complaint-action='cancelled']
#  Click Element                         ${locator.ModalOK}
#  Input text                            name=cancellationReason    test
#  Click Element                         xpath=//button[@class='bidAction']



###############################################################################################################
####################################    Переговорна процедура    ##############################################
###############################################################################################################

Скасувати закупівлю
  [Arguments]  ${username}  ${tenderID}  ${cancellation_reason}  ${document}  ${new_description}
#  Log Many   ${USERS.users['${username}'].cancellation_data}
#  Log Many   ${USERS.users['${username}'].cancellation_data.document}
  Switch browser                  ${username}
  Go To                           ${USERS.users['${username}'].homepage}
#  Wait Until Page Contains        Держзакупівлі.онлайн   10
#  Пошук тедера в Мої Закупівлі    ${tenderID}
#  Sleep   1
#  Click Element               xpath=//a[@class="button tenderCancelCommand"]
#  Click Element               ${locator.ModalOK}
  Sleep   1
#  Execute Javascript          $('input[name=upload]').css({ visibility: "visible", height: "20px", width: "40px"}); $('#jAlertBack').remove();
#  Choose File                 name=upload                                            ${document} 
#  Input text                  name=title                                             set var document here
#  Click Element               xpath=//button[@class="icons icon_upload relative"]
#  Input text                  name=reason                                            ${cancellation_reason}
#  Click Element               xpath=//button[@class="bidAction"]
#  Sleep   2
#  Execute Javascript          modalClose();


Модифікувати закупівлю
  [Arguments]  ${username}  ${tenderID}
  Log  __DONE__
#  Пошук тедера в Мої Закупівлі         ${tenderID}
# ПОТРІБНО ДОПИСАТИ КЕЙВОРД КОЛИ БУДЕ РЕАЛІЗОВАНИЙ СЛОВНИК З ДАНИМИ ДЛЯ МОДИФІКАЦІЇ


Пошук тедера в Мої Закупівлі
  [Arguments]  ${tenderID}
#  Click Element                       xpath=//a[@href="/cabinet/tenders/purchase"]
#  Click Element                       xpath=//div[@class="cd"][span[2][contains(text(),"${tenderID}")]]/preceding-sibling::h2/a
  Log  __DONE__


Додати і підтвердити постачальника
  [Arguments]  ${username}  ${tenderID}  ${supplier_data}
#  ${supplierLegalName}=       Get From Dictionary   ${supplier_data.data.suppliers[0].identifier}     legalName
#  ${supplierIdentifier}=      Get From Dictionary   ${supplier_data.data.suppliers[0].identifier}     id
#  ${supplierScheme}=          Get From Dictionary   ${supplier_data.data.suppliers[0].identifier}     scheme
#  ${supplierCountryName}=     Get From Dictionary   ${supplier_data.data.suppliers[0].address}        countryName
#  ${supplierRegion}=          Get From Dictionary   ${supplier_data.data.suppliers[0].address}        region
#  ${supplierLocality}=        Get From Dictionary   ${supplier_data.data.suppliers[0].address}        locality
#  ${supplierStreetAddress}=   Get From Dictionary   ${supplier_data.data.suppliers[0].address}        streetAddress
#  ${supplierPostalCode}=      Get From Dictionary   ${supplier_data.data.suppliers[0].address}        postalCode
#  ${supplierName}=            Get From Dictionary   ${supplier_data.data.suppliers[0].contactPoint}   name
#  ${supplierEmail}=           Get From Dictionary   ${supplier_data.data.suppliers[0].contactPoint}   email
#  ${supplierTelephone}=       Get From Dictionary   ${supplier_data.data.suppliers[0].contactPoint}   telephone
#  ${supplierUrl}=             Get From Dictionary   ${supplier_data.data.suppliers[0].identifier}     uri  
#  ${supplierValueAmount}=     Get From Dictionary   ${supplier_data.data.value}                       amount   

#  Пошук тедера в Мої Закупівлі            ${tenderID}
#  Click Element                           xpath=//a[@class="button reverse addAward"]
#  Click Element                           ${locator.ModalOK}
#  Input text                              name=data[suppliers][0][name]                     ${supplierLegalName}                     
#  Input text                              name=data[suppliers][0][identifier][id]           ${supplierIdentifier}
#  Select From List By Value               name=data[suppliers][0][identifier][scheme]       ${supplierScheme}
#  Select From List By Value               name=data[suppliers][0][address][countryName]     ${supplierCountryName}
#  Select From List By Value               name=data[suppliers][0][address][region]          ${supplierRegion}
#  Input text                              name=data[suppliers][0][address][locality]        ${supplierLocality}
#  Input text                              name=data[suppliers][0][address][streetAddress]   ${supplierStreetAddress}
#  Input text                              name=data[suppliers][0][address][postalCode]      ${supplierPostalCode}
#  Input text                              name=data[suppliers][0][contactPoint][name]       ${supplierName}
#  Input text                              name=data[suppliers][0][contactPoint][email]      ${supplierEmail}
#  Input text                              name=data[suppliers][0][contactPoint][telephone]  ${supplierTelephone}
#  Input text                              name=data[suppliers][0][contactPoint][url]        ${supplierUrl}
#  Input text                              name=data[value][amount]                          ${supplierValueAmount}
#  Execute Javascript                      $(".message").scrollTop(1000);
#  Sleep   1
#  Click Element              xpath=//div[@class="bidDocuments addAward"]//button[@type="submit"]
#  Sleep   3
#  Execute Javascript         modalClose();
#  Capture Page Screenshot
#  Click Element              xpath=//span[@class="awardActionItem"]/a
#  Input text                 name=title    test_doc
#  Execute Javascript         $('input[name=upload]').css({ visibility: "visible", height: "20px", width: "40px"}); $('#jAlertBack').remove();
#  Choose File                name=upload     /home/username/robot_tests/src/robot_tests.broker.dzo/testFileForUpload.txt
#  Click Element              xpath=//button[@class="icons icon_upload relative"]
  Sleep   2
#  Capture Page Screenshot
#  Click Element              xpath=//button[@class="bidAction"]
  Capture Page Screenshot
#  Sleep   2
#  Execute Javascript         modalClose(); 
#  Sleep   300 
  Reload Page
#  Click Element              xpath=//span[@class="awardActionItem awardActionSign"]//a
#  Click Element              xpath=//a[@class="reverse button tenderSignCommand"]
  Sleep   1
#  Select From List By Label  id=CAsServersSelect                          Тестовий ЦСК АТ "ІІТ"
#  Choose File                id=PKeyFileInput                             /home/username/robot_tests/src/robot_tests.broker.dzo/Key-6.dat
#  Input text                 id=PKeyPassword                              qwerty
#  Click Element              id=PKeyReadButton
#  Wait Until Page Contains   Горобець                                      10
#  Click Element              id=SignDataButton
#  Wait Until Page Contains   Підпису успішно накладено та передано у ЦБД   30
