#!/usr/bin/env python3
"""
JSON Schema Validation Script for BC Building Code
Validates BuildingCode.json against schema.json and reports detailed errors.
"""

import json
import sys
from pathlib import Path
from jsonschema import Draft7Validator
from jsonschema.exceptions import SchemaError


def load_json_file(file_path):
    """Load and parse a JSON file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        return None
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in '{file_path}': {e}")
        return None
    except Exception as e:
        print(f"Error: Failed to read '{file_path}': {e}")
        return None


class CustomValidationError:
    """Custom validation error that formats messages without failed values."""
    def __init__(self, original_error):
        self.original_error = original_error
        self.absolute_path = original_error.absolute_path
        self.schema_path = original_error.schema_path
        self.validator = original_error.validator
        self.validator_value = original_error.validator_value
        self.schema = original_error.schema
        self.instance = original_error.instance
        
    @property
    def message(self):
        """Generate a clear error message with actual values."""
        validator = self.validator
        validator_value = self.validator_value
        actual_value = self.instance
        
        # Helper function to format actual value
        def format_actual_value(value):
            if value is None:
                return "null"
            elif isinstance(value, str):
                if len(value) > 50:
                    return f"[{value[:47]}...]"
                else:
                    return f"[{value}]"
            elif isinstance(value, (int, float, bool)):
                return f"[{value}]"
            elif isinstance(value, list):
                return f"array with {len(value)} items"
            elif isinstance(value, dict):
                return f"object with {len(value)} properties"
            else:
                return f"[{str(value)[:50]}]"
        
        # Get type name for the actual value
        def get_type_name(value):
            if value is None:
                return "null"
            elif isinstance(value, str):
                return "string"
            elif isinstance(value, int):
                return "integer"
            elif isinstance(value, float):
                return "number"
            elif isinstance(value, bool):
                return "boolean"
            elif isinstance(value, list):
                return "array"
            elif isinstance(value, dict):
                return "object"
            else:
                return type(value).__name__
        
        actual_type = get_type_name(actual_value)
        formatted_value = format_actual_value(actual_value)
        
        # Create clear error messages based on validator type
        if validator == "type":
            expected_type = validator_value
            if isinstance(expected_type, list):
                types_str = " or ".join(expected_type)
                return f"{actual_type} {formatted_value} is not of type {types_str}"
            else:
                return f"{actual_type} {formatted_value} is not of type {expected_type}"
        
        elif validator == "anyOf":
            return f"{actual_type} {formatted_value} does not match any of the allowed schemas"
        
        elif validator == "oneOf":
            return f"{actual_type} {formatted_value} does not match exactly one of the allowed schemas"
        
        elif validator == "allOf":
            return f"{actual_type} {formatted_value} does not match all required schemas"
        
        elif validator == "required":
            missing_props = validator_value
            if isinstance(missing_props, list):
                props_str = ", ".join(f"'{prop}'" for prop in missing_props)
                return f"Missing required properties: {props_str}"
            else:
                return f"Missing required property: '{missing_props}'"
        
        elif validator == "additionalProperties":
            return "Additional properties are not allowed"
        
        elif validator == "enum":
            allowed_values = validator_value
            return f"{actual_type} {formatted_value} is not one of: {allowed_values}"
        
        elif validator == "pattern":
            return f"{actual_type} {formatted_value} does not match pattern {validator_value}"
        
        elif validator == "minLength":
            return f"{actual_type} {formatted_value} is too short (minimum length: {validator_value})"
        
        elif validator == "maxLength":
            return f"{actual_type} {formatted_value} is too long (maximum length: {validator_value})"
        
        elif validator == "minimum":
            return f"{actual_type} {formatted_value} is too small (minimum: {validator_value})"
        
        elif validator == "maximum":
            return f"{actual_type} {formatted_value} is too large (maximum: {validator_value})"
        
        elif validator == "minItems":
            return f"{actual_type} {formatted_value} has too few items (minimum: {validator_value})"
        
        elif validator == "maxItems":
            return f"{actual_type} {formatted_value} has too many items (maximum: {validator_value})"
        
        else:
            # Fallback with actual value
            return f"{actual_type} {formatted_value} validation failed: {str(self.original_error.message)}"


def validate_json_schema2(data, schema):
    """Validate JSON data against schema and return validation errors."""
    try:
        validator = Draft7Validator(schema)
        original_errors = list(validator.iter_errors(data))
        # Wrap errors in our custom error class
        custom_errors = [CustomValidationError(error) for error in original_errors]
        return custom_errors
    except SchemaError as e:
        print(f"Error: Invalid schema: {e}")
        return None
    except Exception as e:
        print(f"Error: Validation failed: {e}")
        return None
    
def validate_json_schema(data, schema):
    try:
        validator = Draft7Validator(schema)
        # Process errors directly instead of double-iteration
        errors = [CustomValidationError(error) for error in validator.iter_errors(data)]
        return errors
    except SchemaError as e:
        print(f"Error: Invalid schema: {e}")
        return None


def format_validation_error(error, file_path, schema_path):
    """Format a validation error for readable output."""
    path = " -> ".join([str(p) for p in error.absolute_path]) if error.absolute_path else "root"
    json_path = "#/" + "/".join([str(p) for p in error.absolute_path]) if error.absolute_path else "#"
    
    # Get the clean error message from our custom error class
    error_message = error.message
    
    return f"""System ID: {file_path}
Main validation file: {file_path}
Schema: {schema_path}
Engine name: JSON Validator
Severity: error
Description: {json_path}: {error_message}
Path: {path}
"""


def main():
    """Main validation function."""
    # Parse command line arguments
    if len(sys.argv) >= 3:
        data_path = Path(sys.argv[1])
        schema_path = Path(sys.argv[2])
    elif len(sys.argv) == 2:
        data_path = Path(sys.argv[1])
        schema_path = Path("schema.json")
    else:
        data_path = Path("BuildingCode.json")
        schema_path = Path("schema.json")
    
    # Convert to absolute paths for better error reporting
    data_path_abs = data_path.resolve()
    schema_path_abs = schema_path.resolve()
    
    print("🔍 Starting JSON schema validation...")
    print(f"Schema file: {schema_path_abs}")
    print(f"Data file: {data_path_abs}")
    
    # Load schema
    print("\n📋 Loading schema...")
    schema = load_json_file(schema_path_abs)
    if schema is None:
        sys.exit(1)
    print("✅ Schema loaded successfully")
    
    # Load data
    print(f"\n📄 Loading {data_path.name}...")
    data = load_json_file(data_path_abs)
    if data is None:
        sys.exit(1)
    print(f"✅ {data_path.name} loaded successfully")
    
    # Validate
    print("\n🔬 Validating JSON against schema...")
    errors = validate_json_schema(data, schema)
    
    if errors is None:
        print("❌ Validation process failed")
        sys.exit(1)
    
    if not errors:
        print(f"✅ Validation successful! {data_path.name} conforms to the schema.")
        return
    
    # Format and display errors
    print(f"\n❌ Validation failed with {len(errors)} error(s):")
    print("=" * 80)
    
    error_details = []
    for i, error in enumerate(errors, 1):
        formatted_error = format_validation_error(error, str(data_path_abs), str(schema_path_abs))
        error_details.append(f"Error #{i}:\n{formatted_error}")
        print(f"Error #{i}:")
        print(formatted_error)
        print("-" * 80)
    
    # Write errors to file for GitHub Actions
    try:
        with open("validation_errors.txt", "w", encoding="utf-8") as f:
            f.write(f"Found {len(errors)} validation error(s):\n\n")
            f.write("\n".join(error_details))
        print(f"📝 Error details written to validation_errors.txt")
    except Exception as e:
        print(f"Warning: Could not write error file: {e}")
    
    print(f"\n💡 Summary: {len(errors)} validation error(s) found")
    print("Please fix these errors before merging the PR.")
    
    # Exit with error code to fail the GitHub Action
    sys.exit(1)


if __name__ == "__main__":
    main()
