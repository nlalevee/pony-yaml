
/*
 * The set of characters that may appear in URI is as follows:
 *
 *      '0'-'9', 'A'-'Z', 'a'-'z', '_', '-', ';', '/', '?', ':', '@', '&',
 *      '=', '+', '$', ',', '.', '!', '~', '*', '\'', '(', ')', '[', ']',
 *      '%'.
 */
class _TagURIScanner is _Scanner
  let _directive: Bool
  let _startMark: YamlMark val
  let _nextScanner: _Scanner
  var _uriEscapesScanner: (None | _URIEscapesScanner) = None
  var uri: (None | String iso)

  new create(directive: Bool, head: (String iso | None), mark: YamlMark val, nextScanner: _Scanner) =>
    _directive = directive
    _startMark = mark
    _nextScanner = nextScanner
    uri = match consume head
          | let s: String iso => consume s
          else recover String.create() end
          end

  fun ref apply(state: _ScannerState): _ScanResult ? =>
    if not state.available() then
      return ScanPaused(this)
    end
    while state.isAlpha() or state.check(';')
            or state.check('/') or state.check('?')
            or state.check(':') or state.check('@')
            or state.check('&') or state.check('=')
            or state.check('+') or state.check('$')
            or state.check(',') or state.check('.')
            or state.check('!') or state.check('~')
            or state.check('*') or state.check('\'')
            or state.check('(') or state.check(')')
            or state.check('[') or state.check(']')
            or state.check('%') do
      /* Check if it is a URI-escape sequence. */
      if state.check('%') then
        let s = _URIEscapesScanner.create(_directive, (uri = None) as String iso^, _startMark, this~_scanEscape())
        _uriEscapesScanner = s
        return s.apply(state)
      else
        uri = state.read((uri = None) as String iso^)
      end

      if not state.available() then
        return ScanPaused(this)
      end
    end

    /* Check if the tag is non-empty. */
    if (uri as String iso).size() == 0 then
      return ScanError(if _directive then "while parsing a %TAG directive" else "while parsing a tag" end,
                _startMark, "did not find expected tag URI")
    end
    _nextScanner.apply(state)

  fun ref _scanEscape(state: _ScannerState): _ScanResult ? =>
    let uriEscapesScanner = _uriEscapesScanner as _URIEscapesScanner
    uri = uriEscapesScanner.escaped = None
    this.apply(state)
