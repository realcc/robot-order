*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${orders}=    Get orders
    ${rows}    ${columns}=    Get table dimensions    ${orders}
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    FOR    ${row}    IN RANGE    ${rows}
        ${order}=    Get Table Row    ${orders}    ${row}
        Close the annoying modal
        Wait Until Keyword Succeeds    5x    1s    Fill the form    ${order}
    END
    Create a ZIP file of receipt PDF files


*** Keywords ***
Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Read table from CSV    orders.csv    header=True
    RETURN    ${orders}

Close the annoying modal
    Click Button    css:button.btn-dark

Fill the form
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath://input[@placeholder="Enter the part number for the legs"]    ${order}[Legs]
    Input Text    address    ${order}[Address]
    ${screenshot}=    Take a screenshot of the robot    ${order}[Order number]
    Click Button    id:order
    Element Should Be Visible    id:order-completion
    ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    Click Button    id:order-another

Store the receipt as a PDF file
    [Arguments]    ${Order number}
    ${order_completion_html}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${order_completion_html}    ${OUTPUT_DIR}${/}${Order number}.pdf
    RETURN    ${OUTPUT_DIR}${/}${Order number}.pdf

Take a screenshot of the robot
    [Arguments]    ${Order number}
    Click Button    id:preview
    Screenshot    css:div#robot-preview-image    ${OUTPUT_DIR}${/}${Order number}.png
    RETURN    ${OUTPUT_DIR}${/}${Order number}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    ${files}=    Create List
    ...    ${screenshot}
    Add Files To Pdf    ${files}    ${pdf}    append=True
    Close Pdf    ${pdf}

Create a ZIP file of receipt PDF files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}
    ...    ${zip_file_name}
    ...    include=*.pdf
