# JSONSchemaValidator

The **JSONSchemaValidator** class is responsible for validating JSON data based on a defined _JSON Schema_. It implements various methods to check types, patterns, numerical constraints, required properties, and schema references (both internal and external). The class utilizes internal functions for JSON manipulation (such as `hb_JSONEncode` and `hb_JSONDecode`), regular expression handling, and making HTTP/file requests when needed.

---

## Main Attributes

- **aErrors**: Array that stores error messages generated during validation.
- **aOnlyCheck**: Array used to store error messages in validation runs that are only checking (without accumulating errors).
- **cSchema**: String containing the JSON Schema in text format.
- **hSchema**: Hash representing the decoded JSON Schema.
- **hRefSchema**: Hash for caching resolved references (both internal and external).
- **hRegexMatch**: Hash used to store compiled regular expressions.
- **lFastMode**: Logical value that, when enabled, stops validation upon finding the first error.
- **lHasError**: Flag indicating whether any validation errors occurred.
- **lOnlyCheck**: Flag to indicate whether validation is running in check-only mode.
- **xJSONData**: Stores the JSON data (already decoded) that will be validated.

---

## Constructor and Configuration Methods

### New(cSchema as character)
- **Description**: Constructor that creates a new instance of the validator and sets the schema to be used.
- **Parameters**:
  - `cSchema`: String containing the JSON Schema.
- **Return**: An instance of the class configured with the provided schema.

### Reset(cSchema as character) as logical
- **Description**: Resets the validator, setting a new schema.
- **Parameters**:
  - `cSchema`: New JSON Schema (in string format).
- **Return**: Boolean indicating whether the new schema was successfully configured.

### SetSchema(cSchema as character) as logical
- **Description**: Sets (or updates) the JSON Schema to be used for validation.
- **Parameters**:
  - `cSchema`: String containing the new JSON Schema.
- **Return**: Boolean indicating whether the schema was successfully set.

### SetFastMode(lFastMode as logical) as logical
- **Description**: Configures fast validation mode. In _fast mode_, validation stops as soon as an error is encountered.
- **Parameters**:
  - `lFastMode`: Logical value (true or false).
- **Return**: Previous mode value (before the change).

---

## Validation Methods

### Validate(cJSONData as character) as logical
- **Description**: Runs validation on JSON data (provided as a string) against the configured schema.
- **Parameters**:
  - `cJSONData`: String containing the JSON data to be validated.
- **Return**: Boolean indicating whether validation completed without errors.

### ValidateObject(xData as anytype, hSchema as hash, cNode as character) as logical
- **Description**: Core method that validates a JSON object (or value) against a specific schema.
- **Parameters**:
  - `xData`: Data (any type) representing the JSON object or value.
  - `hSchema`: Hash containing the schema rules to be applied.
  - `cNode`: String indicating the current path/node in the JSON structure (used for error tracking).
- **Return**: Boolean indicating whether the object conforms to the schema.

### GetErrors() / HasError()
- **Description**:
  - **GetErrors()**: Returns the array of errors accumulated during validation.
  - **HasError()**: Returns a logical value indicating whether any validation errors occurred.
- **Return**: Array of errors or boolean, respectively.

---

## Specific Check Methods

### AddError(cNode as character, cError as character)
- **Description**: Adds an error message associated with a specific node in the JSON structure.
- **Parameters**:
  - `cNode`: Identifier of the node where the error occurred.
  - `cError`: Descriptive error message.

### CheckType(xValue as anytype, xType as anytype, cNode as character) as logical
- **Description**: Checks whether the type of `xValue` matches the expected type defined in `xType`. Supports both a single string and an array of strings.
- **Parameters**:
  - `xValue`: Value to be checked.
  - `xType`: Expected type or array of expected types.
  - `cNode`: Current path/node for error tracking.
- **Return**: Boolean indicating whether the type is correct.

### CheckEnum(xValue as anytype, aEnum as array, cNode as character) as logical
- **Description**: Checks whether the given value (`xValue`) matches any of the values defined in the enumeration list (`aEnum`).
- **Parameters**:
  - `xValue`: Value to be validated.
  - `aEnum`: Array containing the allowed values.
  - `cNode`: Reference node for error tracking.
- **Return**: Boolean indicating whether the value is valid.

### CheckFormat(cValue as character, cFormat as character, cNode as character) as logical
- **Description**: Validates a string value according to predefined formats (e.g., _date-time_, _date_, _time_, _duration_, _email_, _hostname_, etc.).
- **Parameters**:
  - `cValue`: String value to be validated.
  - `cFormat`: Expected format (string).
  - `cNode`: Node where validation is occurring.
- **Return**: Boolean indicating whether the value meets the specified format.

---

## Reference Resolution Methods ($ref)

To handle internal and external references in the schema (_JSON Reference_), the class implements the following methods:

### ResolveRef(cRef as character, cNode as character) as hash
- **Description**: Determines whether the reference is internal or external (based on the first character) and calls the appropriate resolution method.
- **Parameters**:
  - `cRef`: String containing the reference (e.g., "#/definitions/Name" or a URL).
  - `cNode`: Current node for error tracking.
- **Return**: Hash containing the resolved schema.

### ResolveInternalRef(cRef as character, cNode as character) as hash
- **Description**: Resolves internal references present within the JSON Schema itself.
- **Parameters**:
  - `cRef`: Internal reference (must start with "#").
  - `cNode`: Current node.
- **Return**: Hash of the schema corresponding to the internal reference.

### ResolveExternalRef(cRef as character, cNode as character) as hash
- **Description**: Resolves external references, retrieving the schema via HTTP or file system based on the given URL or path.
- **Parameters**:
  - `cRef`: External reference (does not start with "#").
  - `cNode`: Node for error tracking and messages.
- **Return**: Hash containing the resolved external schema.

---

## Usage Example

```harbour
// Create an instance with the JSON Schema
LOCAL oValidator := JSONSchemaValidator():New( cMyJSONSchema )

// Optional: enable fast validation mode
oValidator:SetFastMode( .T. )

// Validate JSON data
IF oValidator:Validate( cMyJSONData )
   ? "Validation successful!"
ELSE
   ? "Errors found:"
   FOR EACH cError IN oValidator:GetErrors()
      ? cError
   NEXT
ENDIF
```

---

This documentation provides a detailed overview of the **JSONSchemaValidator** class and can serve as a reference for developers looking to integrate or extend JSON validation functionality based on schemas.
