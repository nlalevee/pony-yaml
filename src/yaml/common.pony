
interface tag CodePointsReader
  be setEncoding(encoding: Encoding)
  be read(codePoints: Array[U32] val)

class Option[T]
  var _value : (None | T)
  new none() => _value = None
  new create(v: T) => _value = consume v
  fun ref set(v: T) => _value = consume v
  fun ref giveup(): T^ ? => (_value = None) as T^
  fun isNone(): Bool => _value is None
  fun value(): T ? => _value as T
//  fun ref run(runner: {(T): T^}) ? => set(runner(giveup()))

class ScanError
  let problem: (None | String)
  let mark: YamlMark val
  let context: String

  new create(problem': (None | String), mark': YamlMark val, context': String) =>
    problem = problem'
    mark = mark'
    context = context'

primitive ScanDone
class ScanPaused
  let nextScanner: _Scanner
  new create(nextScanner': _Scanner) => nextScanner = nextScanner'

type _ScanResult is (ScanDone | ScanPaused | ScanError)

interface _Scanner
  fun ref apply(state: _ScannerState): _ScanResult ?

class _YamlSimpleKey
  /** Is a simple key possible? */
  var possible: Bool
  /** Is a simple key required? */
  var required: Bool
  /** The number of the token. */
  var tokenNumber: USize
  /** The position mark. */
  var mark: YamlMark val
  new createStub() =>
    possible = false
    required = false
    tokenNumber = 0
    mark = recover val YamlMark.create() end
  new create(possible': Bool, required': Bool, tokenNumber': USize, mark': YamlMark val ) =>
    possible = possible'
    required = required'
    tokenNumber = tokenNumber'
    mark = mark'

class YamlMark is Equatable[YamlMark box]
  /** The position index. */
  var index: USize
  /** The position line. */
  var line: USize
  /** The position column. */
  var column: USize

  new create(index': USize = 0, line': USize = 0, column': USize = 0) =>
    index = index'
    line = line'
    column = column'

  new val newval(index': USize = 0, line': USize = 0, column': USize = 0) =>
    index = index'
    line = line'
    column = column'

  fun clone(): YamlMark val =>
    let i = index
    let l = line
    let c = column
    recover val YamlMark.create(i, l, c) end

  fun eq(that: YamlMark box): Bool =>
    (that.index == this.index) and (that.line == this.line) and (that.column == this.column)
