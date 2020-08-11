import strutils
import ka2token, ka2lexer, ka2node

# パーサクラス
type Parser = ref object of RootObj
  lexer: Lexer
  curToken: Token
  peekToken: Token
  errors: string

# プロトタイプ宣言
proc parseExpression(p: Parser, precedence: Precedence): Node
proc parseStatement(p: Parser): Node
proc parseBlockStatement(p: Parser, endTokenTypes: seq[string]): BlockStatement
proc parseCallExpression(p: Parser, left: Node): Node
proc parseExpressionList(p: Parser, endToken: string): seq[Node]

# パーサクラスのインスタンスを作る
proc newParser(l: Lexer): Parser =
  let p = Parser(
    lexer: l,
    curToken: l.nextToken(),
    peekToken: l.nextToken(),
  )
  return p

# curTokenとpeekTokenを一つ進める
proc shiftToken(p: Parser) =
  p.curToken = p.peekToken
  p.peekToken = p.lexer.nextToken()

# 変数定義
proc parseLetStatement(p: Parser): Node =
  let node = Node(
    kind: nkLetStatement,
    token: p.curToken,
  )
  if p.peekToken.Type != IDENT:
    return Node(kind: nkNil)
  
  p.shiftToken()
  node.let_name = Node(
    kind: nkIdent,
    token: p.curToken,
    identValue: p.curToken.Literal,
  )
  if p.peekToken.Type != ASSIGN:
    return node
  
  p.shiftToken()
  p.shiftToken()
  node.let_value = p.parseExpression(Lowest)
  return node

# 関数定義
# TODO DO-END
proc parseDefineStatement(p: Parser): Node =
  var node = Node(
    kind: nkDefineStatement,
    token: p.curToken,
  )
  if p.peekToken.Type != IDENT:
    return Node(kind: nkNil)

  p.shiftToken()
  node.define_name = Node(
    kind: nkIdent,
    token: p.curToken,
    identValue: p.curToken.Literal
  )
  
  if p.peekToken.Type != LPAREN:
    return Node(kind: nkNil)
  p.shiftToken()
  node.define_args = p.parseExpressionList(RPAREN)
  p.shiftToken()
  if p.peekToken.Type != ASSIGN:
    return node
  p.shiftToken()
  if p.peekToken.Type != DO:
    return node
  p.shiftToken()
  node.define_block = p.parseBlockStatement(@[END])
  return node

# 中置演算子の処理
proc parseInfixExpression(p: Parser, left: Node): Node =
  let operator = p.curToken.Type
  let cp = p.curToken.tokenPrecedence()
  p.shiftToken()
  let right = p.parseExpression(cp)
  let node = Node(
    kind:  nkInfixExpression,
    token:      p.curToken,
    operator:   operator,
    left:       left,
    right:      right,
  )
  return node

# 引数の処理
proc parseExpressionList(p: Parser, endToken: string): seq[Node] =
  var list = newSeq[Node]()
  if p.peekToken.Type == endToken:
    p.shiftToken()
    return list

  p.shiftToken()
  list.add(p.parseExpression(Lowest))
  while p.peekToken.Type == COMMA:
    p.shiftToken()
    p.shiftToken()
    list.add(p.parseExpression(Lowest))
  
  return list

# 関数呼び出しの処理
proc parseCallExpression(p: Parser, left: Node): Node =
  var node = Node(
    kind: nkCallExpression,
    token:     p.curToken,
    function:  left,
  )
  p.shiftToken()
  node.args = p.parseExpressionList(RPAREN)
  return node
  # TODO

# 名前
proc parseIdent(p: Parser): Node =
  let node = Node(
    kind: nkIdent,
    token: p.curToken,
    identValue: p.curToken.Literal,
  )
  return node

# 整数値リテラル
proc parseIntLiteral(p: Parser): Node =
  let node = Node(
    kind: nkIntLiteral,
    token: p.curToken,
    intValue: p.curToken.Literal.parseInt
  )
  return node

# 小数値リテラル
proc parseFloatLiteral(p: Parser): Node =
  let node = Node(
    kind: nkFloatLiteral,
    token: p.curToken,
    floatValue: p.curToken.Literal.parseFloat
  )
  return node

# 真偽値リテラル
proc parseBoolLiteral(p: Parser): Node =
  let node = Node(
    kind: nkBoolLiteral,
    token: p.curToken,
    boolValue: p.curToken.Literal.parseBool
  )
  return node

# 文字リテラル
proc parseCharLiteral(p: Parser): Node =
  let node = Node(
    kind: nkCharLiteral,
    token: p.curToken,
    charValue: p.curToken.Literal[0],
  )
  return node

# 文字列リテラル
proc parseStringLiteral(p: Parser): Node =
  let node = Node(
    kind: nkStringLiteral,
    token: p.curToken,
    stringValue: p.curToken.Literal,
  )
  return node

# if式
proc parseIfExpression(p: Parser): Node =
  var node = Node(
    kind: nkIfExpression,
    token: p.curToken,
  )
  p.shiftToken()
  node.condition = p.parseExpression(Lowest)
  
  if p.peekToken.Type != DO:
    return Node(kind: nkNil)
  node.consequence = p.parseBlockStatement(@[END, ELSE])
  # elseがあった場合
  if p.curToken.Type == ELSE:
    node.kind = nkIfAndElseExpression
    p.shiftToken()
    if p.curToken.Type != DO:
      return Node(kind: nkNil)
    else:
      node.alternative = p.parseBlockStatement(@[END])
      return node
  
  return node

# 式の処理
proc parseExpression(p: Parser, precedence: Precedence): Node =
  var left: Node
  case p.curToken.Type
  of IDENT  : left = p.parseIdent()
  of INT    : left = p.parseIntLiteral()
  of FLOAT  : left = p.parseFloatLiteral()
  of CHAR   : left = p.parseCharLiteral()
  of STRING : left = p.parseStringLiteral()
  of TRUE   : left = p.parseBoolLiteral()
  of FALSE  : left = p.parseBoolLiteral()
  else:      left = nil
  
  while precedence < p.peekToken.tokenPrecedence() and p.peekToken.Type != SEMICOLON:
    case p.peekToken.Type
    of PLUS, MINUS, ASTERISC, SLASH, LT, GT:
      p.shiftToken()
      left = p.parseInfixExpression(left)
    of LPAREN:
      left = p.parseCallExpression(left)
    else:
      return left
  
  return left

# 式文の処理
proc parseExpressionStatement(p: Parser): Node =
    let node = p.parseExpression(Lowest)
    if p.peekToken.Type == SEMICOLON:
      p.shiftToken()
    return node

# ブロック文の処理
proc parseBlockStatement(p: Parser, endTokenTypes: seq[string]): BlockStatement =
  var bs = BlockStatement(token: p.curToken)
  var endLoop = false
  bs.statements = newSeq[Node]()

  p.shiftToken()
  while p.curToken.Type != EOF:
    for ett in endTokenTypes:
      if p.curToken.Type == ett:
        endLoop = true
        break
    if endLoop:
      break
    else:
      let statement = p.parseStatement()
      if statement != nil:
        bs.statements.add(statement)
      p.shiftToken()
  
  return bs

# 文の処理
proc parseStatement(p: Parser): Node =
  case p.curToken.Type
  of "LET":    return p.parseLetStatement()
  of "DEFINE": return p.parseDefineStatement()
  of "IF":     return p.parseIfExpression()
  else:        return p.parseExpressionStatement()

# ASTを作る
proc makeAST*(input: string): Node =
  var lex = newLexer(input)
  let tree = lex.newParser().parseStatement()
  return tree