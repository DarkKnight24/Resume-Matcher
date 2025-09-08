PROMPT = """
You are a JSON-extraction engine specializing in job posting analysis. Convert the following raw job posting text into exactly the JSON schema below:
— Do not add any extra fields or prose.
— Use "YYYY-MM-DD" for all dates.
— Ensure any URLs (website, applyLink) conform to URI format.
— Do not change the structure or key names; output only valid JSON matching the schema.
- Do not format the response in Markdown or any other format. Just output raw JSON.

CRITICAL REQUIREMENTS FOR KEYWORD EXTRACTION:
- You MUST extract at least 5 relevant keywords for the "extractedKeywords" field.
- Keywords should include: technical skills, software tools, programming languages, methodologies, industry terms, and job-specific terminology mentioned in the posting.
- If explicit keywords are not clearly stated, infer relevant keywords from the job responsibilities, qualifications, and requirements.
- Keywords MUST be relevant to the job position and industry.
- NEVER return an empty keywords list. If unsure, include general terms related to the job title and industry.

Schema:
```json
{0}
```

Job Posting:
{1}

Note: Please output only a valid JSON matching the EXACT schema with no surrounding commentary.
"""
