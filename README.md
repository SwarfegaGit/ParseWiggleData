# ParseWiggleData
This PowerShell function can be used to scrape/parse the wiggle.co.uk website for prices of items. Helpful if you are waiting for an item to go on sale.

Copy and paste the following code into PowerShell.  This needs to be copied each and very time you close and re-open the PowerShell Window unless you save it in your PowerShell Profile which is ran automatically each time you run PowerShell.

````powershell
function ParseWiggleData {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]] $Uri
    )
    
    foreach ($U in $Uri) {

        Try {

            $Item = (
                (Invoke-WebRequest -Uri $U -ErrorAction Stop).RawContent | Select-String -Pattern '(?<=window\.universal_variable\.product = ).*'
            ).Matches.Value | ConvertFrom-Json

            $Item.skus | ForEach-Object {
                [PSCustomObject]@{
                    Name            = $Item.Name
                    Manufacturer    = $Item.manufacturer
                    Category        = $Item.category
                    Colour          = $PSItem.color
                    Size            = $PSItem.size
                    InStock         = $PSItem.in_stock
                    UnitPrice       = $PSItem.unit_price
                    UnitSalePrice   = $PSItem.unit_sale_price
                    DiscountPercent = ($PSItem.unit_price - $PSItem.unit_sale_price) / $PSItem.unit_price * 100 -as [int]
                }
            }

        }
        catch {
            Write-Error -Message "Error scraping the Uri '$U'"
        }
    }

}
````
This above will create a new function called ParseWiggleData which can be used to scrape/parse items on wiggle.co.uk.  Example:

````powershell
ParseWiggleData -Uri 'https://www.wiggle.co.uk/dhb-windproof-cycling-gloves'
````

If you are using Windows you can use Out-GridView to create an Excel like GUI output which makes viewing this data easier.  Example:

````powershell
ParseWiggleData -Uri 'https://www.wiggle.co.uk/dhb-windproof-cycling-gloves' | Out-GridView
````

Multiple Uri's can be passed to the function, simply use a comma (,) to seperate them. Example:
````powershell
ParseWiggleData -Uri 'https://www.wiggle.co.uk/high5-energy-gel-mixed-pack-20-x-40g', 'https://www.wiggle.co.uk/garmin-forerunner-965-gps-watch' | Out-GridView
````

As with all things CLI the output can be manipulated however you see fit.  For example appending the output to a file on your computer to keep a record of product pricing each day.

````powershell
ParseWiggleData -Uri 'https://www.wiggle.co.uk/vango-micro-steel-chair' | Select-Object -Property @{Name='DateTime';Expression={Get-Date}}, Name, InStock, UnitPrice, UnitSalePrice, DiscountPercent | Export-Csv C:\Myfolder\WiggleData.csv -NoTypeInformation -Append
````
