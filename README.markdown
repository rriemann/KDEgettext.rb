# Install
 * maybe you need first: *gem sources -a http://gems.github.com`
 * `gem install kdegettext` for your standard ruby version
 * `gem1.9 install kdegettext` for other ruby versions (command may be slightly differ on your ruby installation)

# Acknowledgments
 * Masao Mutoh ( author of gettext package for ruby)
   * How-To write a parser: http://www.yotabanana.com/hiki/ruby-gettext-howto-poparser.html
 * Richard Dale ( some helpful links, author of korundum/qtruby package )
 * the author of that piece of code found on http://www.koders.com/ruby/fidA7A93BC839C40D00497E6BB33479BAC9430FE50C.aspx?s="Chris+Wanstrath"#L20

# Bugs
 * in ruby1.8 the hash (TargetList) is not sorted -> output in po is not sorted for line numbers
 * **IMPORTANT!**: This program might work only in a login console (`su - user`) and/or with ruby v1.9

# Dependencies
 * should me installed automatically via gem
 * otherwise manual installation via
   * ruby 1.8: `gem    install locale gettext ruby_parser sexp_processor`
   * ruby 1.9: `gem1.9 install locale gettext ruby_parser sexp_processor`

# Usage
 * `kdegettext.rb file_1.rb [file2_rb, ...]`
 * with other ruby version: `ruby1.9 /usr/bin/kgettext.rb file_1.rb [file2_rb, ...]`