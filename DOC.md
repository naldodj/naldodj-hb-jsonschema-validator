# JSONValidator Documentation

The `JSONValidator` class is a Harbour-based implementation of a JSON schema validator. It is designed to decode a JSON schema, validate JSON data against it, and report errors for mismatches in data type, structure, and constraints. The validator supports a range of schema features including type checking, enumeration, pattern matching, minimum/maximum validations, and unique item checks for arrays.

## Overview

The JSON validator provides the following functionalities:
- **Schema Setup:** Accepts a JSON schema (as a string) and decodes it into an internal hash structure.
- **Data Validation:** Validates JSON data against the schema, handling different JSON data types (object, array, string, number, boolean, and null).
- **Error Handling:** Collects error messages during validation. In fast mode (`lFastMode`), it stops at the first error encountered; otherwise, it continues to accumulate all errors.
- **Type & Constraint Checking:** Validates values according to schema properties such as type, required properties, enumerations, numeric constraints (minimum, maximum, exclusive limits, and multipleOf), string constraints (minLength, maxLength, pattern), and array-specific constraints (minItems, maxItems, uniqueItems, and contains).

## Class Data Members

- **aErrors (Array):** Stores error messages generated during the validation process.
- **aOnlyCheck (Array):** Temporary array for holding errors when performing sub-checks (e.g., for array `contains` checks).
- **cSchema (Character):** The original JSON schema provided as a string.
- **hSchema (Hash):** The decoded JSON schema stored as a Harbour hash.
- **hJSONData (Hash):** The decoded JSON data being validated.
- **lFastMode (Logical):** When set to `.T.` (true), the validator stops at the first error encountered.
- **lHasError (Logical):** Indicates if any errors were found during validation.
- **lOnlyCheck (Logical):** Used internally to control error collection when only checking a part of the schema.

## Constructor

### `New(cSchema as character)`

Creates a new instance of the `JSONValidator` and initializes it with the provided JSON schema.

- **Parameters:**  
  - `cSchema`: A string containing the JSON schema.
- **Returns:**  
  - The instance of `JSONValidator`.

**Usage Example:**
```harbour
oJSONValidator := JSONValidator():New(cSchema)
```

## Methods

### `AddError(cError)`

Adds an error message to the error collection.

- **Parameters:**  
  - `cError`: The error message (string) to add.
- **Notes:**  
  - If `lOnlyCheck` is active, the error is added to `aOnlyCheck`; otherwise, it is added to `aErrors`.

---

### `SetSchema(cSchema as character) as logical`

Sets the JSON schema for the validator. This method decodes the schema and stores it in the internal hash (`hSchema`).

- **Parameters:**  
  - `cSchema`: A string with the JSON schema.
- **Returns:**  
  - A logical value indicating whether the schema was successfully set.
- **Notes:**  
  - In case of an error during decoding, an error message is added.

---

### `Reset(cSchema as character) as logical`

Resets the validator with a new JSON schema by calling `SetSchema`.

- **Parameters:**  
  - `cSchema`: A new JSON schema string.
- **Returns:**  
  - A logical value indicating whether the reset was successful.

---

### `Validate(cJSONData as character) as logical`

Validates the provided JSON data string against the stored schema.

- **Parameters:**  
  - `cJSONData`: A JSON data string.
- **Returns:**  
  - A logical value (`.T.` if valid, `.F.` if errors were found).
- **Process:**  
  1. Decodes the JSON data.
  2. Calls `ValidateObject` to recursively validate the data.
  3. Sets `lHasError` based on whether errors were accumulated.
  
**Usage Example:**
```harbour
lValid := oJSONValidator:Validate(cJSONData)
```

---

### `ValidateObject(xData as anytype, hSchema as hash, cPath as character) as logical`

Recursively validates an object or value against the corresponding part of the JSON schema.

- **Parameters:**  
  - `xData`: The data to validate (can be any type).
  - `hSchema`: The portion of the schema (as a hash) relevant for `xData`.
  - `cPath`: A string representing the current path in the JSON structure (useful for error messages).
- **Returns:**  
  - A logical value indicating if the object is valid.
- **Notes:**  
  - Performs type checking, required property validation, and property-specific validations based on schema definitions.

---

### `CheckType(xValue as anytype, xType as anytype, cPath as character) as logical`

Checks whether `xValue` matches the expected type (`xType`).

- **Parameters:**  
  - `xValue`: The value to check.
  - `xType`: The expected type. This can be a string (e.g., `"string"`, `"number"`) or an array of possible types.
  - `cPath`: The current path in the JSON structure.
- **Returns:**  
  - `.T.` if the type matches; otherwise, `.F.`.
- **Notes:**  
  - Adds an error message if there is a type mismatch.
  - Uses the helper static function `__HB2JSON` to convert Harbour type codes into JSON type names.

---

### `CheckEnum(xValue as anytype, aEnum as array, cPath as character) as logical`

Validates that the given value is one of the allowed enumerated values.

- **Parameters:**  
  - `xValue`: The value to validate.
  - `aEnum`: An array of allowed values.
  - `cPath`: The current path in the JSON structure.
- **Returns:**  
  - `.T.` if `xValue` is allowed; otherwise, `.F.`.
- **Notes:**  
  - An error message is added if the validation fails.

---

### `CheckNumber(nValue as numeric, hSchema as hash, cPath as character) as logical`

Checks a numeric value against the schema constraints for numbers, including:
- Type check for `"number"` or `"integer"`.
- Multiple-of constraints.
- Minimum, maximum, exclusiveMinimum, and exclusiveMaximum limits.

- **Parameters:**  
  - `nValue`: The numeric value to check.
  - `hSchema`: The schema hash that may contain numeric constraints.
  - `cPath`: The current path in the JSON structure.
- **Returns:**  
  - `.T.` if the number is valid; otherwise, `.F.`.
- **Notes:**  
  - Handles floating-point tolerance when checking `multipleOf`.

---

### `CheckString(cValue as character, hSchema as hash, cPath as character) as logical`

Validates a string value against the schema. Checks include:
- Minimum and maximum length.
- Pattern matching via a regular expression.

- **Parameters:**  
  - `cValue`: The string value.
  - `hSchema`: The schema hash that may include string constraints.
  - `cPath`: The current path in the JSON structure.
- **Returns:**  
  - `.T.` if the string is valid; otherwise, `.F.`.

---

### `CheckPattern(cValue as character, cPattern as character, cPath as character) as logical`

Uses regular expression matching to verify if `cValue` conforms to `cPattern`.

- **Parameters:**  
  - `cValue`: The string value.
  - `cPattern`: The regex pattern.
  - `cPath`: The current path in the JSON structure.
- **Returns:**  
  - `.T.` if the string matches the pattern; otherwise, `.F.`.
- **Notes:**  
  - Invokes the static helper `__regexMatch` for pattern matching.

---

### `CheckRequired(hData as hash, aRequired as array, cPath as character) as logical`

Ensures that the required properties (specified in `aRequired`) exist in the given object.

- **Parameters:**  
  - `hData`: The data object (hash) to check.
  - `aRequired`: An array of property names that are required.
  - `cPath`: The current path in the JSON structure.
- **Returns:**  
  - `.T.` if all required properties are present; otherwise, `.F.`.
- **Notes:**  
  - If `hData` is not an object, an error is reported.

---

### `CheckArray(aValues as array, hSchema as hash, cPath as character) as logical`

Validates an array against the schema. It performs several checks:
- Validates each element in the array against the defined schema for items.
- Supports `uniqueItems` constraint to ensure all items in the array are unique.
- If a `contains` constraint is present, counts how many array items satisfy the condition and validates them against `minContains` and `maxContains`.

- **Parameters:**  
  - `aValues`: The array of values.
  - `hSchema`: The schema hash that defines array constraints.
  - `cPath`: The current path in the JSON structure.
- **Returns:**  
  - `.T.` if the array is valid; otherwise, `.F.`.
- **Notes:**  
  - Uses temporary error collections (`aOnlyCheck`) when checking the `contains` condition.

---

## Static Helper Functions

### `__HB2JSON(cType as character) as character`

Converts Harbour internal type codes into corresponding JSON type names.

- **Parameters:**  
  - `cType`: A single-character Harbour type code (e.g., `"C"` for character, `"N"` for number).
- **Returns:**  
  - A string with the JSON type name (e.g., `"string"`, `"number"`, `"object"`).

---

### `__regexMatch(cString as character, cPattern as character) as logical`

Performs a regex match on `cString` against the provided regular expression pattern.

- **Parameters:**  
  - `cString`: The string to test.
  - `cPattern`: The regex pattern.
- **Returns:**  
  - `.T.` if a match is found; otherwise, `.F.`.
- **Notes:**  
  - Compiles the regex in a case-sensitive manner without multi-line matching.

---

## Usage Example

Below is a sample snippet showing how to instantiate and use the JSON validator:

```harbour
// Create a new JSONValidator with the provided schema
local oJSONValidator := JSONValidator():New(cSchema)

// Validate some JSON data
local lValid := oJSONValidator:Validate(cJSONData)

if (lValid)
    QOut("JSON data is valid!")
else
    QOut("JSON data is invalid. Errors:")
    for each error in oJSONValidator:aErrors
        QOut("  " + error)
    next
endif
```

## Error Handling and Fast Mode

- **Fast Mode (`lFastMode`):** When enabled, the validator exits on the first error encountered.
- **Error Collection:** All error messages are stored in `aErrors`. When performing sub-checks (such as for `contains` in arrays), temporary errors may be stored in `aOnlyCheck`.

---

## Conclusion

The `JSONValidator` class is a comprehensive tool for validating JSON data against a defined schema. It provides detailed feedback for any discrepancies between the JSON data and the schema, making it easier to identify and correct issues in JSON documents.

This documentation provides an overview of the class structure, method functionalities, and usage patterns. Adjust or extend the documentation as needed to match your project's requirements.

---
