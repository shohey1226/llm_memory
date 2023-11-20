At this point of wriging this readme (Nov 20, 2023), we use RAGAS to evaluate RAG. To use ragas from llm_memory, we do the following steps.

#### 1. Prepare test data with the following format

```
test_data = [
 {
    question: "Is it better to stay with my child during lessons, or should they be left alone?",
    contexts: [],
    answer: "",
    ground_truths: ["To improve English proficiency, we recommend that children take lessons by themselves as much as possible. However, if your child is unable to concentrate, we ask that parents support their child. If you need to facilitate smooth progress in the lesson (for instance, by informing us of your child's interests to help with teacher-student conversations), please consult with the Student Relations department."]
 },
 # Prepare multiple question and groud_truths. 10 ~ 20 (Note that the groud truth is not mandatory)
]
```

#### 2. Use llm_memory to fill the `contexts` and `answer`

```
test_data = [...] 

hippocampus = LlmMemory::Hippocampus.new(index_name: "sr_emails")  

prompt = <<-TEMPLATE
    # YOUR PROMT
    <%= query_str %>

    Use the following info to respond
    ---------------------
    <% related_docs.each do |doc| %>
    <%= doc[:content] %>
    <% end %>
    ---------------------
    TEMPLATE

test_data.each{|td| 
  related_docs = hippocampus.query(td[:question], limit: 10)
  td[:contexts] = related_docs
 
    broca = LlmMemory::Broca.new(
      prompt: prompt, 
      model: "gpt-4",
      temperature: 0,
      max_token: 8192
    )
    message = broca.respond(query_str: td[:question], related_docs: related_docs)
    td[:answer] = message
}
```

#### 3. Dump to file like JSON or YAML 

```
File.open('out.yaml', 'w') do |f|  f.write(test_data.to_yaml) end
system('curl -F "file=@out.yaml" https://file.io') # heroku to upload the file
```

#### 4. Install python/ragas

Set python environment if it's not there yet.

```
$ pip install ragas
```

#### 5. Create a python script to do the evaluation

```
import yaml
from datasets import Dataset
from ragas import evaluate
import os

# Load the YAML file
file_path = 'out.yaml'
with open(file_path, 'r') as file:
    yaml_data = yaml.safe_load(file)

# Updated parsing function to create a dictionary with lists for each column
def parse_data(yaml_data):
    # Initialize a dictionary with keys and empty lists
    parsed_data = {
        'question': [],
        'contexts': [],
        'answer': [],
        'ground_truths': []
    }

    # Populate the dictionary
    for item in yaml_data:
        parsed_data['question'].append(item[':question'])
        parsed_data['contexts'].append([context[':content'] for context in item[':contexts']])
        parsed_data['answer'].append(item[':answer'])
        parsed_data['ground_truths'].append(item[':ground_truths'])

    return parsed_data

# Convert the YAML data to the required format
parsed_yaml_data = parse_data(yaml_data)

# Create the dataset
dataset = Dataset.from_dict(parsed_yaml_data)
for row in dataset:
    print(row)

# Run RAGAS evaluation
results = evaluate(dataset)
print(results)
```

#### 5. Execute it
Name the previous script as `evaluate.py` and run it with the environment variable.

```
$ RAGAS_DO_NOT_TRACK=true OPENAI_API_KEY=YOUR_KEY python evaluate.py
...
{'answer_relevancy': 0.7575, 'context_precision': 0.5574, 'faithfulness': 0.7167, 'context_recall': 0.1250}  
```