import json


def parse_agent_run_response(raw_json):
    """
    Simplifies the raw JSON response from the agent to a more readable list of dictionaries
    with only the relevant fields: title, extensive_summary, sentiment, source, publication_date.

    Parameters:
        raw_json (str or list): Raw JSON string or already parsed JSON list.

    Returns:
        list: Simplified list of dictionaries.
    """
    # Parse the JSON if it's a string
    if isinstance(raw_json, str):
        data = json.loads(raw_json)
    else:
        data = raw_json

    simplified = []

    for item in data:
        parts = item.get("content", {}).get("parts", [])
        for part in parts:
            # Check if this part has a functionResponse with a result
            function_response = part.get("functionResponse", {})
            response = function_response.get("response", {})
            result_str = response.get("result")

            if result_str:
                try:
                    # Load the JSON string inside result
                    result_json = json.loads(result_str)
                    for article in result_json:
                        simplified.append(
                            {
                                "title": article.get("title"),
                                "extensive_summary": article.get("extensive_summary"),
                                "sentiment": article.get("sentiment"),
                                "source": article.get("source"),
                                "publication_date": article.get("publication_date"),
                            }
                        )
                except json.JSONDecodeError:
                    # Skip if result_str is not valid JSON
                    continue

    return simplified
