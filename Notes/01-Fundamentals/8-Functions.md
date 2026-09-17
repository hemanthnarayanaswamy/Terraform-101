# Functions

## What are Functions?

Terraform functions are built-in features that help with simple management and manipulation of data within your Terraform configurations, enabling you to perform data transformations and ensure smooth infrastructure provisioning. 

Terraform's built-in functions include a variety of utilities to transform and combine values such as string formatting, arithmetic calculations, and working with lists and maps directly in your code.

---

## Why Use Functions?

Terraform functions are important for tasks such as variable interpolation, generating resource names, and applying conditional logic:

- String manipulation
- List processing
- Map processing
- Data transformation
- Validation
- Dynamic configuration

## Function Syntax

```hcl
function_name(argument1, argument2, ...)
upper("terraform")
length(var.zones)
```

---

## Common Terraform Function Categories

<table class="table__component"><thead class="table__head"><tr class="table__row"><th class="table__header" width="20%">Category </th><th width="30%" class="table__header">Description </th><th class="table__header">Examples</th></tr></thead><tbody class="table__body"><tr class="table__row"><td class="table__cell cc-feature">String </td><td class="table__cell">Manipulate and transform strings</td><td class="table__cell"><span class="code">join(separator, list)</span>, <span class="code">split(separator, string)</span>, <span class="code">replace(string, search, replace)</span>, <span class="code">trimspace(string)</span> etc.</td></tr><tr class="table__row"><td class="table__cell cc-feature">Numeric </td><td class="table__cell">Perform arithmetic operations</td><td class="table__cell"><span class="code">abs(number)</span>, <span class="code">ceil(number), floor(number)</span>, <span class="code">pow(number, power)</span> etc.</td></tr><tr class="table__row"><td class="table__cell cc-feature">Collection</td><td class="table__cell">Work with lists, maps, and sets</td><td class="table__cell"><span class="code">length(list or map)</span>, <span class="code">element(list, index)</span>, <span class="code">flatten(list)</span>, <span class="code">merge(map1, map2, ...)</span> etc. </td></tr><tr class="table__row"><td class="table__cell cc-feature">Date and Time </td><td class="table__cell">Work with date and time values</td><td class="table__cell"><span class="code">timestamp()</span>, <span class="code">timeadd(timestamp, duration)</span>, <span class="code">formatdate(format, timestamp)</span> etc.</td></tr><tr class="table__row"><td class="table__cell cc-feature">Encoding </td><td class="table__cell">Encode and decode values, and transform data formats</td><td class="table__cell"><span class="code">base64encode(string)</span>, <span class="code">base64decode(string)</span>, <span class="code">jsondecode(string)</span>, <span class="code">yamlencode(value)</span> etc. </td></tr><tr class="table__row"><td class="table__cell cc-feature">Hash and Crypto </td><td class="table__cell">Create hashes, UUIDs, and encrypted value helpers</td><td class="table__cell"><span class="code">sha256(string)</span>, <span class="code">base64sha256(string)</span>, <span class="code">uuid()</span> etc.</td></tr><tr class="table__row"><td class="table__cell cc-feature">Type Conversion </td><td class="table__cell">Convert between different types</td><td class="table__cell"><span class="code">tostring(value)</span>, <span class="code">tonumber(value)</span>, <span class="code">toset(value) etc.</span></td></tr><tr class="table__row"><td class="table__cell cc-feature">Filesystem</td><td class="table__cell">Read files from the filesystem</td><td class="table__cell"><span class="code">file(path)</span>, <span class="code">filebase64(path)</span>, <span class="code">dirname(path)</span> etc.</td></tr><tr class="table__row"><td class="table__cell cc-feature">IP Network </td><td class="table__cell">Work with IP addresses and networks</td><td class="table__cell"><span class="code">cidrnetmask(prefix)</span>, <span class="code">cidrsubnets(prefix, newbits...)</span> etc.</td></tr><tr class="table__row"><td class="table__cell cc-feature">Terraform-specific </td><td class="table__cell">Encode and decode Terraform language values</td><td class="table__cell"><span class="code">provider::terraform::encode_tfvars(value)</span>, <span class="code">provider::terraform::decode_tfvars(string)</span> etc.</td></tr></tbody></table>

---

# String Functions

This category focuses on string-related functions, making it easier to construct and manipulate strings within your code. This can be particularly useful for naming resources, generating tags, and formatting output values.

#### 1. `upper()`/`lower()`
Converts text to uppercase and Converts text to lowercase.

```hcl
upper("terraform") - TERRAFORM

lower("TERRAFORM") - terraform
```
#### 2. `title()`
Capitalizes each word.

```hcl
title("google cloud platform")

Google Cloud Platform
```
#### 3. `trim()`
Removes characters from both ends.

```hcl
trim("--terraform--", "-")

terraform
```
#### 4. `replace(string, search, replacement)`
Replace text.

```hcl
replace("dev-api", "dev", "prod")

prod-api
```

#### 5. `split(separator, string)`
Break string into list.

```hcl
split("-", "dev-api")

["dev", "api"]
```

#### 6. `join(separator, list)`
Combine list into string.

```hcl
join("-", ["dev", "api"])

dev-api
```

#### 7. `substr(string, offset, length)`
Extract part of a string by offset and length.

```hcl
substr("terraform", 0, 4)

terr
```

#### 8. `chomp()`
Removes newline characters from the end of a string.

```hcl
chomp("terraform\n")

terraform
```

#### 9. `startswith()`
Checks whether a string begins with a prefix.

```hcl
startswith("dev-api", "dev")

true
```

#### 10. `endswith()`
Checks whether a string ends with a suffix.

```hcl
endswith("dev-api", "api")

true
```

#### 11. `strcontains()`
Checks whether one string contains another string.

```hcl
strcontains("dev-api", "api")

true
```

#### 12. `trimprefix()`
Removes a prefix from the start of a string.

```hcl
trimprefix("dev-api", "dev-")

api
```

#### 13. `trimsuffix()`
Removes a suffix from the end of a string.

```hcl
trimsuffix("dev-api", "-api")

dev
```

#### 14. `trimspace()`
Removes whitespace from the start and end of a string.

```hcl
trimspace("  terraform  ")

terraform
```

#### 15. `strrev()`
Reverses the characters in a string.

```hcl
strrev("terraform")

mrofarret
```

#### 16. `format()`
Creates a formatted string.

```hcl
format("%s-%s", "dev", "api")

dev-api
```

#### 17. `formatlist()`
Creates a list of formatted strings.

```hcl
formatlist("server-%s", ["a", "b"])

["server-a", "server-b"]
```

#### 18. `indent()`
Adds spaces to each line after the first line.

```hcl
indent(2, "line1\nline2")

line1
  line2
```

#### 19. `regex()`
Returns the first match from a regular expression.

```hcl
regex("[a-z]+", "env123")

env
```

#### 20. `regexall()`
Returns all matches from a regular expression.

```hcl
regexall("[0-9]+", "subnet-10-zone-2")

["10", "2"]
```

#### 21. `templatestring()`
Renders a string as a template using variables.

```hcl
locals {
  greeting_template = "hello $${name}"
}

templatestring(
  local.greeting_template,
  {
    name = "terraform"
  }
)

hello terraform
```

The template argument should be a reference, not a direct string literal.
The `$${name}` syntax keeps the placeholder literal until `templatestring()` renders it.

---
---

# Numeric Functions
Numeric-related functions help execute calculations on numeric values, such as rounding numbers or getting absolute values.

1. `max()`: Largest value.
```hcl
max(10, 20, 30)
30
```
2. `min()`: Smallest value.
```hcl
min(10, 20, 30)
10
```
3. `abs()`: Absolute value.
```hcl
abs(-10)
10
```
4. `ceil()`: Round up.
```hcl
ceil(4.1)
5
```
5. `floor()`: Round down.
```hcl
floor(4.9)
4
```
6. `log()`: Logarithm of a number in a specific base.
```hcl
log(100, 10)
2
```
7. `parseint()`: Parse a string as an integer in a specific base.
```hcl
parseint("ff", 16)
255
```
8. `pow()`: Raise a number to a power.
```hcl
pow(2, 3)
8
```
9. `signum()`: Return the sign of a number.
```hcl
signum(-10)
-1
```
---


# Collection Functions

This category focuses on handling and manipulating lists and maps, making working with complex data structures in your configurations easier. These functions are useful for counting elements, retrieving specific items, flattening nested lists, and merging maps.

### 1. `length(list)`
Returns number of elements.

```hcl
length(["a","b","c"])

3
```

### 2. `contains()`
Checks if collection contains value.

```hcl
contains(["dev","test","prod"], "prod")

true
```

### 3. `distinct()`
Removes duplicates.

```hcl
distinct(["a","a","b","c"])

["a","b","c"]
```

### 4. `sort()`
Sort list.

```hcl
sort(["c","a","b"])

["a","b","c"]
```

### 5. `reverse()`
Reverse list.

```hcl
reverse(["a","b","c"])

["c","b","a"]
```

### 6. `element()`
Retrieve item by index.

```hcl
element(["a","b","c"],1)

b
```

### 7. `keys() / values()`
* Get map keys and values respectively.

```hcl
keys({
  env = "dev"
  app = "api"
})

[
  "app",
  "env"
]

values({
  env = "dev"
  app = "api"
})

[
  "api",
  "dev"
]
```

### 8. `alltrue()`
Returns true when all values in a collection are true.

```hcl
alltrue([true, true, true])
true
```

### 9. `anytrue()`
Returns true when at least one value in a collection is true.

```hcl
anytrue([false, true, false])
true
```

### 10. `chunklist()`
Splits one list into smaller fixed-size lists.

```hcl
chunklist(["a", "b", "c", "d"], 2)

[["a", "b"], ["c", "d"]]
```

### 11. `coalesce()`
Returns the first value that is not null or an empty string.

```hcl
coalesce(null, "", "dev")

dev
```

### 12. `coalescelist()`
Returns the first list that is not empty.

```hcl
coalescelist([], ["dev"], ["prod"])

["dev"]
```

### 13. `compact()`
Removes null and empty string values from a list.

```hcl
compact(["a", "", null, "b"])

["a","b"]
```

---

### 14. `concat()`
Combines multiple lists into one list.

```hcl
concat(["a"], ["b", "c"])

["a","b","c"]
```

### 15. `flatten()`
Flattens nested lists into a single list.

```hcl
flatten([["a", "b"], ["c"]])

["a","b","c"]
```

### 16. `index()`
Returns the index of the first matching list value.

```hcl
index(["a", "b", "c"], "b")

1
```

### 17. `lookup()`
Gets a value from a map and returns a default value when the key is missing.

```hcl
lookup({env = "dev"}, "team", "platform")

platform
```

### 18. `matchkeys()`
Returns values whose matching keys are present in a search list.

```hcl
matchkeys(["alice", "bob", "carol"],["dev", "prod", "dev"],["dev"])

["alice","carol"]
```

### 19. `merge()`
Combines maps or objects into one value. Later arguments win when keys overlap.

```hcl
merge({ env = "dev" }, { app = "api" })

{app = "api", env = "dev"}
```

### 20. `range()`
Generates a list of numbers.

```hcl
range(1, 5)

[1,2,3,4]
```

### 21. `setintersection()`
Returns values that exist in all sets.

```hcl
setintersection(toset(["a", "b"]), toset(["b", "c"]))

["b"]
```

### 22. `setproduct()`
Returns every combination from multiple sets or lists. Similar to ***Cross Join*** in SQL

```hcl
setproduct(["dev", "prod"], ["web", "api"])

[
  ["dev", "web"],
  ["dev", "api"],
  ["prod", "web"],
  ["prod", "api"]
]
```

### 23. `setsubtract()`
Returns values from the first set that are not in the second set.

```hcl
setsubtract(toset(["a", "b", "c"]),toset(["b"])
)

["a","c"]
```

### 24. `setunion()`
Combines multiple sets and keeps unique values.

```hcl
setunion(
  toset(["a", "b"]),
  toset(["b", "c"])
)

["a", "b","c"]
```

### 25. `slice()`
Returns a portion of a list.

```hcl
slice(["a", "b", "c", "d"], 1, 3)

["b", "c"]
```

### 26. `sum()`
Returns the sum of numbers in a list or set.

```hcl
sum([10, 20, 30])

60
```

### 27. `transpose()`
Swaps keys and values in a map of string lists.

```hcl
transpose({
  app = ["api", "web"]
  env = ["api"]
})

{
  api = ["app", "env"]
  web = ["app"]
}
```

### 28. `zipmap()`
Creates a map from a list of keys and a list of values.

```hcl
zipmap(["env", "app"], ["dev", "api"])

{
  app = "api"
  env = "dev"
}
```
---
---

# Type Conversion Functions

1. `tostring()`: Convert to string.

```hcl
tostring(100) -> "100"
```
2. `tonumber()` Convert to number.

```hcl
tonumber("100") -> 100
```
3. `tolist()` Convert to list.

```hcl
tolist(["a","b"])
```

4. `tomap()` Convert to map.

```hcl
tomap({
  env = "dev"
})
```

5. `toset()` Convert list to set. Unique values only.

```hcl
toset(["a","a", "b"])

["a","b"]
```

6. `tobool()` Convert to boolean.

```hcl
tobool("true")
```

### 7. `can()` 
Tests whether an expression can be evaluated without an error.

```hcl
can(tonumber("abc"))

false
```

***Useful in variable validation.***

### 8. `try()`
Returns the first expression that does not fail.

```hcl
try(tomap({app = "api"})["env"],"dev")

dev
```

***Useful when working with optional attributes.***

### 9. `type()`
Returns the type of a value.

```hcl
type("terraform") -> string
```
10.  `sensitive()` Marks a value as sensitive.

```hcl
sensitive("secret-password")

(sensitive value)
```
11. `issensitive()` Checks whether Terraform treats a value as sensitive.

```hcl
issensitive(sensitive("secret-password"))
```
12. `nonsensitive()` Removes the sensitive mark from a value.

```hcl
nonsensitive(sensitive("secret-password"))
```
Use carefully because it exposes the value.

13. `ephemeralasnull()` Converts an ephemeral value to null.

```hcl
ephemeralasnull(var.session_token)

null when the value is ephemeral
```
---
---

# Terraform-Specific Functions

These functions use Terraform's built-in provider-defined function syntax.

Useful for:
- Generating `.tfvars` content
- Reading `.tfvars` content
- Generating Terraform expression syntax

## 1. `provider::terraform::encode_tfvars()`
Converts an object into `.tfvars` file content.

```hcl
provider::terraform::encode_tfvars({
  env   = "dev"
  count = 2
})

env = "dev"
count = 2
```

## 2. `provider::terraform::decode_tfvars()`
Converts `.tfvars` file content into an object.

```hcl
provider::terraform::decode_tfvars(
  "env = \"dev\""
)

{env = "dev"}
```

## 3. `provider::terraform::encode_expr()`
Converts a Terraform value into Terraform expression syntax.

```hcl
provider::terraform::encode_expr({
  env = "dev"
})

{
  env = "dev"
}
```
---
---

# Encoding Functions

### 1. `jsonencode()`
Convert Terraform object to JSON.

```hcl
jsonencode({env = "dev"})

{"env":"dev"}
```

### 2. `jsondecode()`
Convert JSON to Terraform object.

```hcl
jsondecode("{\"env\":\"dev\"}")

{env = "dev"}
```

### 3. `base64encode()`
Convert string to Base64.

```hcl
base64encode("terraform")  ---> dGVycmFmb3Jt
```

### 4. `base64decode()`
Convert Base64 back to string.

```hcl
base64decode("dGVycmFmb3Jt") ---> terraform
```

### 5. `base64gzip()`
Compress a string with gzip and then Base64 encode it.

```hcl
base64gzip("terraform")

Base64 encoded gzip content
```

***Useful for compressed startup scripts or user data.***

### 6. `csvdecode()`
Convert CSV text into a list of maps.

```hcl
csvdecode("name,env\napi,dev")

[
  {
    env  = "dev"
    name = "api"
  }
]
```

### 7. `textencodebase64()`
Encode text using a specific character encoding, then Base64 encode it.

```hcl
textencodebase64("terraform", "UTF-8")

dGVycmFmb3Jt
```

### 8. `textdecodebase64()`
Decode Base64 text using a specific character encoding.

```hcl
textdecodebase64("dGVycmFmb3Jt", "UTF-8")

terraform
```

### 9. `urlencode()`
URL-encode a string.

```hcl
urlencode("env=dev api")

env%3Ddev+api
```

### 10. `yamlencode()`
Convert a Terraform value to YAML.

```hcl
yamlencode({
  env = "dev"
})

env: dev
```

### 11. `yamldecode()`
Convert YAML into a Terraform value.

```hcl
yamldecode("env: dev")

{env = "dev"}
```

---
---

# Hash and Crypto Functions

Terraform hash and crypto functions are useful for checksums, stable IDs, password hashes, and cloud API inputs that expect encoded hashes.

1. `md5(str)` Returns an MD5 hash as hexadecimal text.
2. `sha1(str)` Returns a SHA-1 hash as hexadecimal text.
3. `sha256(str)` Returns a SHA-256 hash as hexadecimal text.
4. `sha512(str)` Returns a SHA-512 hash as hexadecimal text.
5. `base64sha256()` Returns a SHA-256 hash encoded with Base64.
6. `base64sha512()` Returns a SHA-512 hash encoded with Base64.
7. `filemd5()` Returns an MD5 hash of a file's contents.
8. `filesha1()` Returns a SHA-1 hash of a file's contents.
9. `filesha256()` Returns a SHA-256 hash of a file's contents.
10. `filesha512()` Returns a SHA-512 hash of a file's contents.
11. `filebase64sha256()` Returns a Base64-encoded SHA-256 hash of a file's contents.
12. `filebase64sha512()` Returns a Base64-encoded SHA-512 hash of a file's contents.
13. `bcrypt()` Returns a bcrypt password hash.
14. `rsadecrypt()` Decrypts Base64-encoded RSA ciphertext with a PEM private key.
15. `uuid()` Generates a random UUID. *Use carefully because the value can change between Terraform runs.*
16. `uuidv5()` Generates a stable UUID from a namespace and name. ***Useful when you need the same UUID for the same input.***

---
---

# Network Functions

Terraform provides built-in networking functions that are commonly used when working with:
- VPCs
- Subnets
- IP Planning
- Multi-region deployments
- GCP Networking
- AWS Networking
- Azure Networking

The most important networking functions are:

```ini
cidrsubnet()
cidrhost()
cidrnetmask()
cidrsubnets()
```

### 1. `cidrsubnet()`
Creates a subnet from an existing network.

```hcl
cidrsubnet(prefix, newbits, netnum)

# Parameters:

prefix  -> Parent CIDR block
newbits -> Number of additional subnet bits
netnum  -> Subnet number
```
EXAMPLE:

```hcl
cidrsubnet("10.0.0.0/16", 8, 1)

10.0.1.0/24
```
***HOW IT WORKS***

Parent Network: `10.0.0.0/16`
Adding: `8 bits`
Creates:  `/24` subnets
Available subnets:
```text
10.0.0.0/24
10.0.1.0/24
10.0.2.0/24
10.0.3.0/24
...
```

### 2. `cidrsubnets()`
Creates multiple consecutive subnet CIDR blocks from one network.

```hcl
cidrsubnets(prefix, newbits...)
```

**Example:**

```hcl
cidrsubnets("10.0.0.0/16",8,8,8)

10.0.0.0/24
10.0.1.0/24
10.0.2.0/24
```
Useful when you need Terraform to allocate several subnets in sequence.

### 3. `cidrhost()`
Returns a specific host IP within a network.

```hcl
cidrhost(prefix, hostnum)

# Parameters:
prefix  -> CIDR block
hostnum -> Host number
```
**Example**

```hcl
cidrhost("10.0.1.0/24",10)  --> 10.0.1.10 # tenth host
cidrhost("10.0.1.0/24",5)  --> 10.0.1.5 # fifth host
cidrhost("10.0.1.0/24",1)  --> 10.0.1.1 # first host
```
**Real Example**

```hcl
locals {
  subnet = cidrsubnet("10.0.0.0/16",8,0)
  gateway = cidrhost(local.subnet,1)
}

Subnet  = 10.0.0.0/24
Gateway = 10.0.0.1
```

### 4. `cidrnetmask()`
Returns the subnet mask from a CIDR block.

```hcl
cidrnetmask("10.0.0.0/24") --> 255.255.255.0

cidrnetmask("10.0.0.0/16") --> 255.255.0.0

cidrnetmask("10.0.0.0/8") --> 255.0.0.0
```
---
---

# Filesystem Functions

Filesystem functions work with files and paths on the machine where Terraform runs.

Useful for:
- Reading startup scripts
- Loading JSON policies
- Reading configuration files
- Loading templates

1. `file()` Reads the contents of a file.

```hcl
file("startup.sh")

<!-- startup.sh:
#!/bin/bash
echo "Hello World" -->

# Entire file contents returned as a string
```

2. `fileexists()` Checks whether a file exists.

```hcl
fileexists("startup.sh") --> true/false
```

3. `fileset()` Returns files matching a pattern. using wild cards

```hcl
fileset(".", "*.tf")

["main.tf","outputs.tf","variables.tf"]
```

4. `dirname()` Returns parent directory.

```hcl
dirname("/home/hemanth/main.tf")

/home/hemanth
```

5. `basename()` Returns final part of path.

```hcl
basename("/home/hemanth/main.tf")

main.tf
```
6. `abspath()` Converts a path to an absolute path.

```hcl
abspath("main.tf")

/home/hemanth/project/main.tf
```
Useful when a provider needs a full local path.

7. `pathexpand()` Expands `~` to the current user's home directory.

```hcl
pathexpand("~/terraform")

/home/hemanth/terraform
```
8. `filebase64()` Reads a file and returns its Base64-encoded contents.

```hcl
filebase64("startup.sh")

Base64 encoded file content
```
Useful when an API expects binary or encoded file content.

9. `templatefile()` Reads a template file and replaces variables.

```hcl
templatefile("${path.module}/startup.tftpl", {
  name = "web"
})

<<-- startup.tftpl: -->>

hello ${name}

hello web
```
10. `path.module` Path of current module.

```hcl
path.module

/modules/network
```
Commonly used with:

```hcl
file("${path.module}/script.sh")
```
11. `path.root` Path of root module.

12. `path.cwd` Current working directory.

---
---

# Date & Time Functions

Terraform provides functions for working with timestamps and dates.

Useful for:
- Naming resources
- Generating unique values
- Expiration calculations
- Logging metadata

1. `timestamp()` Returns the current UTC timestamp.

```hcl
timestamp() --> 2026-08-28T17:00:00Z
```

2. `formatdate()` Formats a timestamp.

```hcl
formatdate(format, timestamp)

formatdate("YYYY-MM-DD", timestamp())  --> 2026-08-28
```
**Common Format Tokens**

- Year: `YYYY`
- Month: `MM`
- Day: `DD`
- Hour: `hh`
- Minute: `mm`
- Seconds: `ss`

3. `timeadd()` Adds time duration.
```hcl
timeadd(timestamp, duration)

timeadd(timestamp(),"24h")
```

4. `plantimestamp()` Returns the UTC timestamp from the time Terraform created the plan.

Useful when you need a stable timestamp across the same plan and apply operation.

5. `timecmp()` Compares two timestamps.

```hcl
timecmp(timestamp_a, timestamp_b)
timecmp("2026-08-28T17:00:00Z", "2026-08-29T17:00:00Z")

-1
```
**Return values:**

```ini
-1 -> First timestamp is earlier
 0 -> Both timestamps are equal
 1 -> First timestamp is later
```
