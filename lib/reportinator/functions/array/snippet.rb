module Reportinator
  class SnippetArrayFunction < ArrayFunction
    PREFIXES = [">snippet"]

    def output
      name = target
      name.strip! if name.instance_of? String
      parsed_name = parse_value(name)
      snippet = find_snippet(parsed_name)
      return "Missing Snippet" unless snippet.present?
      parse_snippet(snippet)
    end

    def find_snippet(name)
      snippets = metadata[:snippets]
      return false unless snippets.present?
      return false unless snippets[name].present?
      snippets[name]
    end

    def parse_snippet(snippet)
      snippet_metadata = metadata.dup
      snippet_metadata.delete :snippets
      variables = values[0]
      parsed_variables = parse_value(variables)
      input_metadata = merge_hash(snippet_metadata, {variables: parsed_variables})
      ValueParser.parse(snippet, input_metadata)
    end
  end
end
