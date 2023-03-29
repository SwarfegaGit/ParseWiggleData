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
