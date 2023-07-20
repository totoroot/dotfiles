all
# View all Markdown rules [here](https://github.com/markdownlint/markdownlint/blob/main/docs/RULES.md)
# Limit maximum line length
rule 'MD013', :line_length => 240
# Allow Inline HTML
exclude_rule 'MD033'
# Allow bare URLS
exclude_rule 'MD034'
