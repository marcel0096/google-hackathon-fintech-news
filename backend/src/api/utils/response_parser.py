import json


def extract_agent_responses(raw_json):
    """
    Parses the raw JSON from the endpoint and extracts the google_agent and twitter_agent responses.
    Cleans the Markdown code fences and returns valid JSON for both feeds.

    Args:
        raw_json (str or dict): The JSON string or dict returned from the endpoint.

    Returns:
        dict: A dictionary containing 'google_feed' and 'twitter_feed' results.
    """
    # Convert to dict if JSON string is provided
    if isinstance(raw_json, str):
        data = json.loads(raw_json)
    else:
        data = raw_json

    result = {"google_feed": None, "twitter_feed": None}

    def clean_markdown_json(raw_str):
        """Remove ```json fences and parse inner JSON"""
        content_str = raw_str.strip()
        if content_str.startswith("```json"):
            content_str = content_str[7:]
        if content_str.endswith("```"):
            content_str = content_str[:-3]
        return json.loads(content_str)

    # Iterate through the top-level array
    for item in data:
        parts = item.get("content", {}).get("parts", [])
        for part in parts:
            function_response = part.get("functionResponse")
            if function_response:
                name = function_response.get("name")
                response_result = function_response.get("response", {}).get("result")
                if response_result:
                    # Clean the Markdown JSON and parse
                    parsed_result = clean_markdown_json(response_result)
                    if name == "google_agent":
                        result["google_feed"] = parsed_result
                    elif name == "twitter_agent":
                        # For Twitter, extract the 'result' array inside 'fetch_X_tool_response'
                        result["twitter_feed"] = parsed_result.get(
                            "fetch_X_tool_response", {}
                        ).get("result", [])

    return result


# Example usage:
# parsed = extract_agent_responses(endpoint_json)
# print(json.dumps(parsed, indent=2))
