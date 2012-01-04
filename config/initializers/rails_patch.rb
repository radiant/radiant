# The following code alters Rails MissingSourceFile to catch errors in Ruby 1.9.3
MissingSourceFile::REGEXPS.push([/^cannot load such file -- (.+)$/i, 1])