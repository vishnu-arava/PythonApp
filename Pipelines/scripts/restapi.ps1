$url = "https://api.restful-api.dev/objects"
$id = "ff8081819071bec7019078f1693c1012"
$headers = @{
    "content-type" = "application/json"
}
#GetType($headers)

$body = @"
{
    "name": "Apple Iphones Pro Series New",
	"data": {
	   "color": "orange",
	   "generation": "17Promax",
	   "price": "200"
	}
}
"@
#POST
Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
#OR
#Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"

$uri = $url+"/"+$id
Write-Host $uri

#PUT
# Update existing Data
#Invoke-RestMethod -Uri $uri -Method Put -Body $body -ContentType "application/json"


# PATCH
$patchbody = @"
{
   "name": "Apple Iphones Pro Series Max (Updated Name)"
}
"@


#Invoke-RestMethod -Uri $uri -Method Patch -Body $patchbody -ContentType "application/json"

# DELETE
#Invoke-RestMethod -Uri $uri -Method Delete
