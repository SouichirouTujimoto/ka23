import g_token

type 
  NodeKind* = enum
    nkRoot
    nkNil
    nkDo
    nkImport
    nkInclude
    nkFilePath
    nkComment
    nkArgs
    nkStatementArgs
    nkIdent
    nkTypeIdent
    nkStruct
    nkMapIdent
    nkFilterIdent
    nkNilLiteral
    nkIntLiteral
    nkFloatLiteral
    nkBoolLiteral
    nkCharLiteral
    nkStringLiteral
    nkCompoundLiteral
    nkCppCode
    nkArrayLiteral
    nkIntType
    nkFloatType
    nkBoolType
    nkCharType
    nkStringType
    nkArrayType
    nkFunctionType
    nkInfixExpression
    nkPrefixOperator
    nkGenerator
    nkAssignExpression
    nkLetStatement
    nkVarStatement
    nkMainStatement
    nkDefineStatement
    nkReturnStatement
    nkExportStatement
    nkRetrunExpression
    nkMapFunction
    nkFilterFunction
    nkForStatement
    nkExpressionStatement
    nkCallExpression
    nkIfExpression
    nkElseExpression
    nkIfStatement
    nkElifStatement
    nkElseStatement
    nkMutStatement
    nkLaterStatement
    nkPipeExpression
    nkAccessElement
    nkDollarExpression
    nkDefaultValue

  Node* = ref object of RootObj
    kind*:          NodeKind
    token*:         Token
    child_nodes*:   seq[Node]

  Precedence* = enum
    Lowest = 0
    Assign
    Pipeline
    TypeIdent
    Ifexpression
    Equals
    Lg
    Sum
    Product
    Generator
    Call
    Prefix

proc tokenPrecedence*(tok: Token): Precedence =
  case tok.Type
  of EQUAL:                     return Assign
  of PIPE:                      return Pipeline
  of IDENT:                     return TypeIdent
  of IFEX, COLON:               return Ifexpression
  of LT, GT, LTE, GTE:          return Lg
  of EE, NE:                    return Equals
  of PLUS, MINUS:               return Sum
  of SLASH, ASTERISC:           return Product
  of LARROW:                    return Generator
  of LPAREN, LBRACKET, LBRACE:  return Call
  of DOLLAR:                    return Prefix
  else:                         return Lowest