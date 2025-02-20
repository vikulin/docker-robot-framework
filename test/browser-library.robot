*** Settings ***
Library			Browser

*** Variables ***
# There is a conflict between browser names used by Selenium (using "chrome") and Browser (using "chromium")
# This is why the browser is currently fixed for the Browser Library.
${BROWSER}		%{BROWSER}

*** Test Cases ***
Visit Bing
    Set Browser Timeout  30 seconds
	IF	"${BROWSER}" == 'chrome'
		New Browser		chromium
	ELSE
		New Browser		${BROWSER}
	END
	New Page			https://www.bing.com
	Take Screenshot

Visit Google
    Set Browser Timeout  30 seconds
	IF	"${BROWSER}" == 'chrome'
		New Browser		chromium
	ELSE
		New Browser		${BROWSER}
	END
	New Page			https://www.google.com
	Take Screenshot

Visit Yahoo
    Set Browser Timeout  30 seconds
	IF	"${BROWSER}" == 'chrome'
		New Browser		chromium
	ELSE
		New Browser		${BROWSER}
	END
	New Page			https://search.yahoo.com
	Take Screenshot
