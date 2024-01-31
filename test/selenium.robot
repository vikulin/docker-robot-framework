*** Settings ***
Library			SeleniumLibrary

*** Variables ***
${BROWSER}		%{BROWSER}

*** Test Cases ***
Visit Bing
    Set Selenium Timeout 	20 seconds
	Open Browser			https://www.bing.com		${BROWSER}
	Capture Page Screenshot

Visit Google
    Set Selenium Timeout 	20 seconds
	Open Browser			https://www.google.com		${BROWSER}
	Capture Page Screenshot
