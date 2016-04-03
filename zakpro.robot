*** Settings ***
Library           Selenium2Screenshots
Library           String
Library           DateTime
Library           zakpro_service.py
Library           zakpro.robot

*** Variables ***
${locator.tenderId}    xpath=//*[@id='content_inner']/article/div[2]/div[2]/div/div/dl/dd[5]    # TenderID
${locator.title}    xpath=//*[@id='id_title']    # Загальна назва закупівлі
${locator.description}    xpath=//*[@id='id_description']    # Предмет закупівлі
${locator.value.amount}    xpath=//*[@id='id_value_amount']    # Максимальний бюджет
${locator.minimalStep.amount}    xpath=//*[@id='id_minimalStep_amount']    # Мінімальний крок зменшення ціни
${locator.enquiryPeriod.endDate}    xpath=//*[@id='id_enquiryPeriod_endDate']    # Завершення періоду обговорення
${locator.tenderPeriod.endDate}    xpath=//*[@id='id_tenderPeriod_endDate']    # Завершення періоду прийому пропозицій
${locator.items[0].deliveryAddress.countryName}    xpath=//*[@id='id_form-0-deliveryAddress_countryName']    # Адреса поставки
${locator.items[0].deliveryDate.endDate}    xpath=//*[@id='id_form-0-deliveryDate_endDate']    # Кінцева дата поставки
${locator.items[0].classification.scheme}    xpath=//*[@id='id_form-0-classification_scheme']    # Клас CPV завжди - CPV
${locator.items[0].classification.id}    xpath=//*[@id='id_form-0-classification_id']    # Клас CPV
${locator.items[0].classification.description}    xpath=//*[@id='id_form-0-classification_description']    # Клас CPV українською мовою
${locator.items[0].additionalClassifications[0].scheme}    xpath=//*[@id='id_form-0-LIST_additionalClassifications0of1_scheme']    # Клас ДКПП завжди
${locator.items[0].additionalClassifications[0].id}    xpath=//*[@id='id_form-0-LIST_additionalClassifications0of1_id']    # Клас ДКПП \ код конкретного предиету закупівлі
${locator.items[0].additionalClassifications[0].description}    xpath=//*[@id='id_form-0-LIST_additionalClassifications0of1_description']    # Клас ДКПП українською мовою
${locator.items[0].quantity}    xpath=//*[@id='id_form-0-quantity']    # Кількість номенклатури закупівлі
${locator.items[0].unit.code}    xpath=//*[@id='id_form-0-unit_code']    # Код одиниці виміру (має відповідати стандарту UN/CEFACT, наприклад - KGM)
${locator.questions[0].title}    \    # question relative
${locator.questions[0].description}    \    # текст запитання
${locator.questions[0].date}    \    # дата питання
${locator.questions[0].answer}    ${EMPTY}

*** Test Cases ***

*** Keywords ***
Підготувати клієнт для користувача
    [Arguments]    @{ARGUMENTS}
    [Documentation]    Відкрити браузер, створити об’єкт api wrapper, тощо
    ...    ${ARGUMENTS[0]} == \ username
    Open Browser    ${USERS.users['${ARGUMENTS[0]}'].homepage}    ${USERS.users['${ARGUMENTS[0]}'].browser}    alias=${ARGUMENTS[0]}
    Set Window Size    @{USERS.users['${ARGUMENTS[0]}'].size}
    Set Window Position    @{USERS.users['${ARGUMENTS[0]}'].position}
    Run Keyword And Ignore Error    Pre Login    ${ARGUMENTS[0]}
    Wait Until Page Contains Element    jquery=a[href="href="/accounts/login/"]
    Click Element    jquery=a[href="href="/accounts/login/"]
    Run Keyword If    '${username}'    != 'Zakpro_Viewer' Login
    Login
    Wait Until Page Contains Element    name=login-username    10
    Sleep    1
    Input text    name=login-username    ${USERS.users['${username}'].login}
    Sleep    2
    Input text    name=login-password    ${USERS.users['${username}'].password}
    Wait Until Page Contains Element    xpath=//button[contains(@class, 'btn')][./text()='Вхід в кабінет']    20
    Click Element    xpath=//*[@id="login_form"]/button

Pre Login
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ${login}=    Get Broker Property By Username    ${ARGUMENTS[0]}    login
    ${password}=    Get Broker Property By Username    ${ARGUMENTS[0]}    password
    Wait Until Page Contains Element    name=siteLogin    10
    Input Text    name=siteLogin    ${login}
    Input Text    name=sitePass    ${password}
    Click Button    xpath=.//*[@id='table1']/tbody/tr/td/form/p[3]/input

Створити тендер
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tender_data
    #{tender_data}=    Add_time_for_GUI_FrontEnds    ${ARGUMENTS[1]}
    ${items}=    Get From Dictionary    ${ARGUMENTS[1].data}    items
    ${title}=    Get From Dictionary    ${ARGUMENTS[1].data}    title
    ${description}=    Get From Dictionary    ${ARGUMENTS[1].data}    description
    ${budget}=    Get From Dictionary    ${ARGUMENTS[1].data.value}    amount
    ${step_rate}=    Get From Dictionary    ${ARGUMENTS[1].data.minimalStep}    amount
    ${items_description}=    Get From Dictionary    ${ARGUMENTS[1].data}    description
    ${quantity}=    Get From Dictionary    ${items[0]}    quantity
    ${countryName}=    Get From Dictionary    ${ARGUMENTS[1].data.procuringEntity.address}    countryName
    ${delivery_end_date}=    Get From Dictionary    ${items[0].deliveryDate}    endDate
    ${delivery_end_date}=    convert_date_to_slash_format    ${delivery_end_date}
    ${cpv}=    Convert To String    Картонки
    ${cpv_id}=    Get From Dictionary    ${items[0].classification}    id
    ${cpv_id1}=    Replace String    ${cpv_id}    -    _
    ${dkpp_desc}=    Get From Dictionary    ${items[0].additionalClassifications[0]}    description
    ${dkpp_id}=    Get From Dictionary    ${items[0].additionalClassifications[0]}    id
    ${dkpp_id1}=    Replace String    ${dkpp_id}    -    _
    ${enquiry_end_date}=    Get From Dictionary    ${ARGUMENTS[1].data.enquiryPeriod}    endDate
    ${enquiry_end_date}=    convert_date_to_slash_format    ${enquiry_end_date}
    ${end_date}=    Get From Dictionary    ${ARGUMENTS[1].data.tenderPeriod}    endDate
    ${end_date}=    convert_date_to_slash_format    ${end_date}
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Wait Until Page Contains Element    jquery=a[href="/tenders/new"]    30
    Click Element    jquery=a[href="/tenders/new"]
    Wait Until Page Contains Element    name=tender_title    30
    Input text    name=tender_title    ${title}
    Input text    name=tender_description    ${description}
    Input text    name=tender_value_amount    ${budget}
    Input text    name=tender_minimalStep_amount    ${step_rate}
    # Додати специфікацю початок
    Input text    name=items[0][item_description]    ${items_description}
    Input text    name=items[0][item_quantity]    ${quantity}
    Input text    name=items[0][item_deliveryAddress_countryName]    ${countryName}
    Input text    name=items[0][item_deliveryDate_endDate]    ${delivery_end_date}
    Click Element    xpath=//a[contains(@data-class, 'cpv')][./text()='Визначити за довідником']
    Select Frame    xpath=//iframe[contains(@src,'/js/classifications/cpv/uk.htm?relation=true')]
    Input text    id=search    ${cpv}
    Wait Until Page Contains    ${cpv_id}
    Click Element    xpath=//a[contains(@id,'${cpv_id1}')]
    Click Element    xpath=.//*[@id='select']
    Unselect Frame
    Click Element    xpath=//a[contains(@data-class, 'dkpp')][./text()='Визначити за довідником']
    Select Frame    xpath=//iframe[contains(@src,'/js/classifications/dkpp/uk.htm?relation=true')]
    Input text    id=search    ${dkpp_desc}
    Wait Until Page Contains    ${dkpp_id}
    Click Element    xpath=//a[contains(@id,'${dkpp_id1}')]
    Click Element    xpath=.//*[@id='select']
    # Додати специфікацю кінець
    Unselect Frame
    Input text    name=plan_date    ${enquiry_end_date}
    Input text    name=tender_enquiryPeriod_endDate    ${enquiry_end_date}
    Input text    name=tender_tenderPeriod_endDate    ${end_date}
    Додати предмет    ${items[0]}    0
    Run Keyword if    '${mode}' == 'multi'    Додати багато предметів    items
    Unselect Frame
    Click Element    xpath= //button[@value='publicate']
    Wait Until Page Contains    Тендер опубліковано    30
    ${tender_UAid}=    Get Text    xpath=//*/section[6]/table/tbody/tr[2]/td[2]
    ${Ids}=    Convert To String    ${tender_UAid}
    Run keyword if    '${mode}' == 'multi'    Set Multi Ids    ${tender_UAid}
    [Return]    ${Ids}

Set Multi Ids
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[1]} == ${tender_UAid}
    ${id}=    Get Text    xpath=//*/section[6]/table/tbody/tr[1]/td[2]
    ${Ids}=    Create List    ${tender_UAid}    ${id}

Додати предмет
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == items
    ...    ${ARGUMENTS[1]} == ${INDEX}
    ${dkpp_desc1}=    Get From Dictionary    ${ARGUMENTS[0].additionalClassifications[0]}    description
    ${dkpp_id11}=    Get From Dictionary    ${ARGUMENTS[0].additionalClassifications[0]}    id
    ${dkpp_1id}=    Replace String    ${dkpp_id11}    -    _
    Wait Until Page Contains Element    xpath=//a[contains(@class, 'addMultiItem')][./text()='Додати предмет закупівлі']
    Click Element    xpath=//a[contains(@class, 'addMultiItem')][./text()='Додати предмет закупівлі']
    ${index} =    Convert To Integer    ${ARGUMENTS[1]}
    ${index} =    Convert To Integer    ${index + 1}
    Wait Until Page Contains Element    name=items[${index}][item_description]    30
    Input text    name=items[${index}][item_description]    ${description}
    Input text    name=items[${index}][item_quantity]    ${quantity}
    Click Element    xpath=(//a[contains(@data-class, 'cpv')][./text()='Визначити за довідником'])[${index} + 1]
    Select Frame    xpath=//iframe[contains(@src,'/js/classifications/cpv/uk.htm?relation=true')]
    Input text    id=search    ${cpv}
    Wait Until Page Contains    ${cpv_id}
    Click Element    xpath=//a[contains(@id,'${cpv_id1}')]
    Click Element    xpath=.//*[@id='select']
    Unselect Frame
    Click Element    xpath=(//a[contains(@data-class, 'dkpp')][./text()='Визначити за довідником'])[${index} + 1]
    Select Frame    xpath=//iframe[contains(@src,'/js/classifications/dkpp/uk.htm?relation=true')]
    Input text    id=search    ${dkpp_desc1}
    Wait Until Page Contains    ${dkpp_id11}
    Click Element    xpath=//a[contains(@id,'${dkpp_1id}')]
    Click Element    xpath=.//*[@id='select']
    Unselect Frame
    Capture Page Screenshot

Додати багато предметів
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == items
    ${Items_length}=    Get Length    ${items}
    : FOR    ${INDEX}    IN RANGE    1    ${Items_length}
    \    Додати предмет    ${items[${INDEX}]}    ${INDEX}

додати предмети закупівлі
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = ${TENDER_UAID}
    ...    ${ARGUMENTS[2]} = 3
    ${period_interval}=    Get Broker Property By Username    ${ARGUMENTS[0]}    period_interval
    ${tender_data}=    prepare_test_tender_data    ${period_interval}    multi
    ${items}=    Get From Dictionary    ${tender_data.data}    items
    ${description}=    Get From Dictionary    ${tender_data.data}    description
    ${quantity}=    Get From Dictionary    ${items[0]}    quantity
    ${cpv}=    Convert To String    Картонки
    ${cpv_id}=    Get From Dictionary    ${items[0].classification}    id
    ${cpv_id1}=    Replace String    ${cpv_id}    -    _
    ${dkpp_desc}=    Get From Dictionary    ${items[0].additionalClassifications[0]}    description
    ${dkpp_id}=    Get From Dictionary    ${items[0].additionalClassifications[0]}    id
    ${dkpp_id1}=    Replace String    ${dkpp_id}    -    _
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Run keyword if    '${TEST NAME}' == 'Можливість додати позицію закупівлі в тендер'    додати позицію
    Run keyword if    '${TEST NAME}' != 'Можливість додати позицію закупівлі в тендер'    видалити позиції

додати позицію
    dzo.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Wait Until Page Contains Element    xpath=//a[./text()='Редагувати']    30
    Click Element    xpath=//a[./text()='Редагувати']
    Додати багато предметів    ${ARGUMENTS[2]}
    Wait Until Page Contains Element    xpath=//button[./text()='Зберегти']    30
    Click Element    xpath=//button[./text()='Зберегти']

видалити позиції
    dzo.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Wait Until Page Contains Element    xpath=//a[./text()='Редагувати']    30
    Click Element    xpath=//a[./text()='Редагувати']
    : FOR    ${INDEX}    IN RANGE    1    ${ARGUMENTS[2]}-1
    \    sleep    5
    \    Click Element    xpath=//a[@class='deleteMultiItem'][last()]
    \    sleep    5
    \    Click Element    xpath=//a[@class='jBtn green']
    Wait Until Page Contains Element    xpath=//button[./text()='Зберегти']    30
    Click Element    xpath=//button[./text()='Зберегти']

Пошук тендера по ідентифікатору
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderId
    Switch browser    ${ARGUMENTS[0]}
    Go To    ${USERS.users['${ARGUMENTS[0]}'].homepage}
    Wait Until Page Contains    Держзакупівлі.онлайн    10
    Click Element    xpath=//a[text()='Закупівлі']
    sleep    1
    Click Element    xpath=//select[@name='filter[object]']/option[@value='tenderID']
    Input text    xpath=//input[@name='filter[search]']    ${ARGUMENTS[1]}
    Click Element    xpath=//button[@class='btn'][./text()='Пошук']
    Wait Until Page Contains    ${ARGUMENTS[1]}    10
    Capture Page Screenshot
    sleep    1
    Click Element    xpath=//a[@class='reverse tenderLink']

Задати питання
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == tenderUaId
    ...    ${ARGUMENTS[2]} == questionId
    ${title}=    Get From Dictionary    ${ARGUMENTS[2].data}    title
    ${description}=    Get From Dictionary    ${ARGUMENTS[2].data}    description
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    dzo.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    sleep    1
    Execute Javascript    window.scroll(2500,2500)
    Wait Until Page Contains Element    xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]    20
    Click Element    xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
    Wait Until Page Contains Element    name=title    20
    Input text    name=title    ${title}
    Input text    xpath=//textarea[@name='description']    ${description}
    Click Element    xpath=//div[contains(@class, 'buttons')]//button[@type='submit']
    Wait Until Page Contains    ${title}    30
    Capture Page Screenshot

Відповісти на питання
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = tenderUaId
    ...    ${ARGUMENTS[2]} = 0
    ...    ${ARGUMENTS[3]} = answer_data
    ${answer}=    Get From Dictionary    ${ARGUMENTS[3].data}    answer
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    dzo.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Execute Javascript    window.scroll(1500,1500)
    Wait Until Page Contains Element    xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]    20
    Click Element    xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
    Wait Until Page Contains Element    xpath=//textarea[@name='answer']    20
    Input text    xpath=//textarea[@name='answer']    ${answer}
    Click Element    xpath=//div[1]/div[3]/form/div/table/tbody/tr/td[2]/button
    Wait Until Page Contains    ${answer}    30
    Capture Page Screenshot

Подати скаргу
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = tenderUaId
    ...    ${ARGUMENTS[2]} = complaintsId
    ${complaint}=    Get From Dictionary    ${ARGUMENTS[2].data}    title
    ${description}=    Get From Dictionary    ${ARGUMENTS[2].data}    description
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    dzo.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    sleep    1
    Execute Javascript    window.scroll(1500,1500)
    Click Element    xpath=//a[@class='reverse openCPart'][span[text()='Скарги']]
    Wait Until Page Contains Element    name=title    20
    Input text    name=title    ${complaint}
    Input text    xpath=//textarea[@name='description']    ${description}
    Click Element    xpath=//div[contains(@class, 'buttons')]//button[@type='submit']
    Wait Until Page Contains    ${complaint}    30
    Capture Page Screenshot

Порівняти скаргу
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = tenderUaId
    ...    ${ARGUMENTS[2]} = complaintsData
    ${complaint}=    Get From Dictionary    ${ARGUMENTS[2].data}    title
    ${description}=    Get From Dictionary    ${ARGUMENTS[2].data}    description
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    dzo.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    sleep    1
    Execute Javascript    window.scroll(1500,1500)
    Click Element    xpath=//a[@class='reverse openCPart'][span[text()='Скарги']]
    Wait Until Page Contains    ${complaint}    30
    Capture Page Screenshot

Внести зміни в тендер
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = description
    #    Тест написано для уже існуючого тендеру, що знаходиться у чернетках користувача
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Click Element    xpath=//a[@class='reverse'][./text()='Мої закупівлі']
    Wait Until Page Contains Element    xpath=//a[@class='reverse'][./text()='Чернетки']    30
    Click Element    xpath=//a[@class='reverse'][./text()='Чернетки']
    Wait Until Page Contains Element    xpath=//a[@class='reverse tenderLink']    30
    Click Element    xpath=//a[@class='reverse tenderLink']
    sleep    1
    Click Element    xpath=//a[@class='button save'][./text()='Редагувати']
    sleep    1
    Input text    name=tender_title    ${ARGUMENTS[1]}
    sleep    1
    Click Element    xpath=//button[@class='saveDraft']
    Wait Until Page Contains    ${ARGUMENTS[1]}    30
    Capture Page Screenshot

обновити сторінку з тендером
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...    ${ARGUMENTS[1]} = tenderUaId
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    dzo.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
    Reload Page

отримати інформацію із тендера
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} == username
    ...    ${ARGUMENTS[1]} == fieldname
    Switch browser    ${ARGUMENTS[0]}
    Run Keyword And Return    Отримати інформацію про ${ARGUMENTS[1]}

Отримати текст із поля і показати на сторінці
    [Arguments]    ${fieldname}
    sleep    1
    ${return_value}=    Get Text    ${locator.${fieldname}}
    [Return]    ${return_value}

отримати інформацію про title
    ${title}=    Отримати текст із поля і показати на сторінці    title
    [Return]    ${title.split('.')[0]}

отримати інформацію про description
    ${description}=    Отримати текст із поля і показати на сторінці    description
    [Return]    ${description}

отримати інформацію про tenderId
    ${tenderId}=    Отримати текст із поля і показати на сторінці    tenderId
    [Return]    ${tenderId}

отримати інформацію про value.amount
    ${valueAmount}=    Отримати текст із поля і показати на сторінці    value.amount
    ${valueAmount}=    Convert To Number    ${valueAmount.split(' ')[0]}
    [Return]    ${valueAmount}

отримати інформацію про minimalStep.amount
    ${minimalStepAmount}=    Отримати текст із поля і показати на сторінці    minimalStep.amount
    ${minimalStepAmount}=    Convert To Number    ${minimalStepAmount.split(' ')[0]}
    [Return]    ${minimalStepAmount}

отримати інформацію про enquiryPeriod.endDate
    ${enquiryPeriodEndDate}=    Отримати текст із поля і показати на сторінці    enquiryPeriod.endDate
    ${enquiryPeriodEndDate}=    subtract_from_time    ${enquiryPeriodEndDate}    6    5
    [Return]    ${enquiryPeriodEndDate}

отримати інформацію про tenderPeriod.endDate
    ${tenderPeriodEndDate}=    Отримати текст із поля і показати на сторінці    tenderPeriod.endDate
    ${tenderPeriodEndDate}=    subtract_from_time    ${tenderPeriodEndDate}    11    0
    [Return]    ${tenderPeriodEndDate}

отримати інформацію про items[0].deliveryAddress.countryName
    ${countryName}=    Отримати текст із поля і показати на сторінці    items[0].deliveryAddress.countryName
    [Return]    ${countryName}

отримати інформацію про items[0].classification.scheme
    ${classificationScheme}=    Отримати текст із поля і показати на сторінці    items[0].classification.scheme
    [Return]    ${classificationScheme.split(' ')[1]}

отримати інформацію про items[0].additionalClassifications[0].scheme
    ${additionalClassificationsScheme}=    Отримати текст із поля і показати на сторінці    items[0].additionalClassifications[0].scheme
    [Return]    ${additionalClassificationsScheme.split(' ')[1]}

отримати інформацію про questions[0].title
    sleep    1
    Click Element    xpath=//a[@class='reverse tenderLink']
    sleep    1
    Click Element    xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
    ${questionsTitle}=    Отримати текст із поля і показати на сторінці    questions[0].title
    ${questionsTitle}=    Convert To Lowercase    ${questionsTitle}
    [Return]    ${questionsTitle.capitalize().split('.')[0] + '.'}

отримати інформацію про questions[0].description
    ${questionsDescription}=    Отримати текст із поля і показати на сторінці    questions[0].description
    [Return]    ${questionsDescription}

отримати інформацію про questions[0].date
    ${questionsDate}=    Отримати текст із поля і показати на сторінці    questions[0].date
    log    ${questionsDate}
    [Return]    ${questionsDate}

отримати інформацію про questions[0].answer
    sleep    1
    Click Element    xpath=//a[@class='reverse tenderLink']
    sleep    1
    Click Element    xpath=//a[@class='reverse openCPart'][span[text()='Обговорення']]
    ${questionsAnswer}=    Отримати текст із поля і показати на сторінці    questions[0].answer
    [Return]    ${questionsAnswer}

отримати інформацію про items[0].deliveryDate.endDate
    ${deliveryDateEndDate}=    Отримати текст із поля і показати на сторінці    items[0].deliveryDate.endDate
    ${deliveryDateEndDate}=    subtract_from_time    ${deliveryDateEndDate}    15    0
    [Return]    ${deliveryDateEndDate}

отримати інформацію про items[0].classification.id
    ${classificationId}=    Отримати текст із поля і показати на сторінці    items[0].classification.id
    [Return]    ${classificationId}

отримати інформацію про items[0].classification.description
    ${classificationDescription}=    Отримати текст із поля і показати на сторінці    items[0].classification.description
    Run Keyword And Return If    '${classificationDescription}' == 'Картонки'    Convert To String    Cartons
    [Return]    ${classificationDescription}

отримати інформацію про items[0].additionalClassifications[0].id
    ${additionalClassificationsId}=    Отримати текст із поля і показати на сторінці    items[0].additionalClassifications[0].id
    [Return]    ${additionalClassificationsId}

отримати інформацію про items[0].additionalClassifications[0].description
    ${additionalClassificationsDescription}=    Отримати текст із поля і показати на сторінці    items[0].additionalClassifications[0].description
    ${additionalClassificationsDescription}=    Convert To Lowercase    ${additionalClassificationsDescription}
    [Return]    ${additionalClassificationsDescription}

отримати інформацію про items[0].quantity
    ${itemsQuantity}=    Отримати текст із поля і показати на сторінці    items[0].quantity
    ${itemsQuantity}=    Convert To Integer    ${itemsQuantity}
    [Return]    ${itemsQuantity}

отримати інформацію про items[0].unit.code
    ${unitCode}=    Отримати текст із поля і показати на сторінці    items[0].unit.code
    Run Keyword And Return If    '${unitCode}'== 'кг'    Convert To String    KGM
    [Return]    ${unitCode}

отримати інформацію про procuringEntity.name
    Log    | Viewer can't see this information on DZO    console=yes

отримати інформацію про enquiryPeriod.startDate
    Log    | Viewer can't see this information on DZO    console=yes

отримати інформацію про tenderPeriod.startDate
    Log    | Viewer can't see this information on DZO    console=yes

отримати інформацію про items[0].deliveryLocation.longitude
    Log    | Viewer can't see this information on DZO    console=yes

отримати інформацію про items[0].deliveryLocation.latitude
    Log    | Viewer can't see this information on DZO    console=yes

отримати інформацію про items[0].deliveryAddress.postalCode
    Log    | Viewer can't see this information on DZO    console=yes

отримати інформацію про items[0].deliveryAddress.locality
    Log    | Viewer can't see this information on DZO    console=yes

отримати інформацію про items[0].deliveryAddress.streetAddress
    Log    | Viewer can't see this information on DZO    console=yes

отримати інформацію про items[0].deliveryAddress.region
    Log    | Viewer can't see this information on DZO    console=yes

отримати інформацію про items[0].unit.name
    Log    | Viewer can't see this information on DZO    console=yes
