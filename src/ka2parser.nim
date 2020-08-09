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
  let node = Node(
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
  if p.peekToken.Type != ASSIGN:
    return node
  
  p.shiftToken()
  p.shiftToken()
  node.define_value = p.parseStatement()
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

# 引数の処理
proc parseCallExpression(p: Parser, left: Node): Node =
  var res = Node(
    kind: nkCallExpression,
    token:     p.curToken,
    function:  left,
  )
  p.shiftToken()
  res.args = p.parseExpressionList(RPAREN)
  return res
  # TODO

# 名前
proc parseIdent(p: Parser): Node =
  let node = Node(
    kind:  nkIdent,
    token:      p.curToken,
    identValue: p.curToken.Literal,
  )
  return node

# 整数リテラル
proc parseIntLiteral(p: Parser): Node =
  let node = Node(
    kind: nkIntLiteral,
    token:     p.curToken,
    intValue:  p.curToken.Literal.parseInt
  )
  return node

# 式の処理
proc parseExpression(p: Parser, precedence: Precedence): Node =
  var left: Node
  case p.curToken.Type
  of IDENT:  left = p.parseIdent()
  of INT:    left = p.parseIntLiteral()
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
    let res = p.parseExpression(Lowest)
    if p.peekToken.Type == SEMICOLON:
      p.shiftToken()
    return res

# 文の処理
proc parseStatement(p: Parser): Node =
  case p.curToken.Type
  of "LET":    return p.parseLetStatement()
  of "DEFINE": return p.parseDefineStatement()
  else:        return p.parseExpressionStatement()

# ASTを作る
proc makeAST*(input: string): Node =
  var lex = newLexer(input)
  let tree = lex.newParser().parseStatement()
  return tree
