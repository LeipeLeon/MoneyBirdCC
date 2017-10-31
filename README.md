# Create financial_statements for CreditCards from Rabobank Telebankieren

## Scenario:

    Usage: ./moneybird.rbx <inputfile> <batchname> [-f]"


Vanuit Rabobank telebankieren kan ik de CC transacties als text kopieeren: b.v:

    30-06-2017	ITUNES.COM/BILL ITUNES.COM IRL	€	12,97	 
    26-06-2017	INCASSO - VORIG OVERZICHT	€	-341,19	 
    ...
    14-06-2017	RICOH IMAGING ONLINEST TOKYO JPN
    Valuta: USD 518,72 Koers: 1,089175853	€	476,25

Copieer deze in het tekst bestand `transactions.txt` (of een andere naam)

run `./moneybird.rbx transactions.txt "CC Mei"` vanaf de commandline.

voeg `-f` toe om daadwerkelijk te posten

Voor het tegen elkaar weg boeken van stortingen maak een hulprekening "CreditCard afrekening" aan en gebruik deze bij het koppelen van de bedragen. (de `INCASSO - VORIG OVERZICHT` op de cc rekening en de afschrijving van de bank zelf)

## Setup

Maak een `.env` bestand aan met de volgende waarden (`cp .env.example .env`):

    # Your administration id found in the URL directly
    # after https://moneybird.com/
    # e.g. https://moneybird.com/17222225412815165311
    ADMINISTRATION_ID=17222225412815165311

    # The bank account where the transactions should be loaded
    # Found w/ the API or exposed in the URL when editing that account
    # e.g. https://moneybird.com/17222225412815165311/financial_accounts/64631818893110654285/edit
    FINANCIAL_ACCOUNT_ID=64631818893110654285

    # The API key generated on the page https://moneybird.com/user/applications
    API_KEY="52ubgqmpxghlgrssd03s1oqf05upkllrsrrv9nvu46kn74o73a3bqqtvqahu1231"

    # Defaults to v2
    API_VERSION=v2

## API documentatie:

https://developer.moneybird.com/
