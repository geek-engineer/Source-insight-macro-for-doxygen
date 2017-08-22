/*!
 *  Insert the doxygen style comments of file.
 */
macro GDoxyFileHeaderComment()
{
    var hwnd
    var hbuf
    /*prepare*/
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    if(hbuf == hNil || hwnd == hNil)
    {
        Msg("Can't open file")
        stop
    }


    /*Get need information*/
    var fFullName
    var fName
    fFullName = GetBufName(hbuf)
    fName = GGetFileName(fFullName)


    var szTime
    var Year
    var Month
    var Day
    szTime = GetSysTime(1)
    Year   = szTime.Year
    Month  = szTime.Month
    Day    = szTime.Day


    var user
    var siInfo
    siInfo = GetProgramEnvironmentInfo()
    user   = siInfo.UserName


    /*Insert comments*/
    ln = 0 //this will cause the file comments will always stay on the top of file
    InsBufLine(hbuf, ln++, "/*!")
    InsBufLine(hbuf, ln++, " * @@file    @fName@")
    InsBufLine(hbuf, ln++, " * @@brief")
    InsBufLine(hbuf, ln++, " *")
    InsBufLine(hbuf, ln++, " * \\n")/*This will let doxygen doc has a empty line*/
    InsBufLine(hbuf, ln++, " * @@details")
    InsBufLine(hbuf, ln++, " *")
    InsBufLine(hbuf, ln++, " * \\n")/*This will let doxygen doc has a empty line*/
    InsBufLine(hbuf, ln++, " * @@version ")
    InsBufLine(hbuf, ln++, " * @@author  @user@")
    InsBufLine(hbuf, ln++, " * @@date    @Year@-@Month@-@Day@")
    InsBufLine(hbuf, ln++, " *")
    InsBufLine(hbuf, ln++, " * @@history")
    InsBufLine(hbuf, ln++, " *")
    InsBufLine(hbuf, ln++, " */")


    /*Locate to the file begin*/
    ScrollWndToLine(hwnd, 0)
}


/*!
 *  Insert doxygen style comments of c++ class.
 */
macro GDoxyClassHeaderComment()
{
    var hwnd
    var hbuf
    var ln
    var symbolrecord
    var name
    var strHeader


    /*prepare*/
    hwnd = GetCurrentWnd()
    hbuf = GetCurrentBuf()
    if(hwnd == hNil || hwnd == hNil)
    {
        Msg("Can't open file")
        stop
    }


    ln = GetBufLnCur(hbuf)
    symbolrecord = GetSymbolLocationFromLn(hbuf, ln)
    if(symbolrecord == Nil)
    {
        Msg("Can't get current symbol record info.")
        stop
    }


    /*check current symbol type*/
    if(symbolrecord.Type != "Class")
    {
        Msg("Current symbol is not a class.")
        stop
    }


    /*Get need info*/
    name = symbolrecord.Symbol


    /*Insert comments*/
    ln = symbolrecord.lnFirst
    strHeader = GGetHeaderSpaceByLn(hbuf, ln)
    InsBufLine(hbuf, ln++, strHeader#"/*!")
    InsBufLine(hbuf, ln++, strHeader#" * @@class @name@")
    InsBufLine(hbuf, ln++, strHeader#" * @@brief")
    InsBufLine(hbuf, ln++, strHeader#" *")
    InsBufLine(hbuf, ln++, strHeader#" * \\n")
    InsBufLine(hbuf, ln++, strHeader#" * @@detail")
    InsBufLine(hbuf, ln++, strHeader#" *")
    InsBufLine(hbuf, ln++, strHeader#" * \\n")
    InsBufLine(hbuf, ln++, strHeader#" */")


    /*Relocate window*/
    ScrollWndToLine(hwnd, symbolrecord.lnFirst)
}


/*!
 *  Insert the doxygen style comments of function.
 */
macro GDoxyFunctionComment()
{
    var hWnd
    var hBuf
    var ln
    var symbolrecord
    var strHeader


    var locateLn  //locate info after insert comments
    var locateCur //locate info after insert comments


    /*prepare*/
    hWnd = GetCurrentWnd()
    hBuf = GetCurrentBuf()
    if(hBuf == hNil || hWnd == hNil)
    {
        Msg("Can't open the file")
        stop
    }


    ln = GetBufLnCur(hBuf)
    symbolrecord = GetSymbolLocationFromLn(hBuf, ln)
    if(symbolrecord == Nil)
    {
        Msg("Can't get current symbol record info.")
        stop
    }


    /*check current symbol type*/
    var type
    type = symbolrecord.Type
    if(type != "Function" && type != "Function Prototype" &&
       type != "Method"   && type != "Method Prototype")
    {
        Msg("Current symbol is not a function.")
        stop
    }


    /*Get need information*/
    ln = symbolrecord.lnFirst
    locateLn = ln + 1 //locate info after insert comments
    strHeader = GGetHeaderSpaceByLn(hBuf, ln)//align with the current function


    //analysis function
    var name
    var type
    var childrenInfo//construct a record.Because SI macro language doesn't have array type, so we append all the info into one string
    var strSeparate
    childrenInfo.count = 0
    childrenInfo.name  = ""
    childrenInfo.type  = ""


    strSeparate = "?"


    var nChild
    var listChild
    listChild = SymbolChildren(symbolrecord)
    nChild    = SymListCount(listChild)
    if(nChild != invalid)
    {
        var idxChildList
        var childsym
        idxChildList = 0
        while(idxChildList < nChild)
        {
            childsym = SymListItem(listChild, idxChildList)
            if(childsym.Type == "Parameter")//function param
            {
                name = GGetStringBySeparateCh(childsym.Symbol#".", ".", 1)


                childrenInfo.count = childrenInfo.count + 1
                childrenInfo.name  = childrenInfo.name#name#strSeparate
                childrenInfo.type  = childrenInfo.type#"FuncParam"#strSeparate
            }
            else if(childsym.Type == "Type Reference")//function type, it referes to the return type
            {
                name = GGetStringBySeparateCh(childsym.Symbol#".", ".", 1)


                childrenInfo.count = childrenInfo.count + 1
                childrenInfo.name  = childrenInfo.name#name#strSeparate
                childrenInfo.type  = childrenInfo.type#"FuncType"#strSeparate
            }
            idxChildList++
        }
    }
    SymListFree(listChild)

	var function
	function = GGetStringBySeparateCh(childsym.Symbol, ".", 0)

    /*Insert comments*/
    InsBufLine(hBuf, ln++, strHeader#"/*!")
    InsBufLine(hBuf, ln++, strHeader#" * @@brief @function@	{ function_description }")//Function description
    locateCur = strlen(strHeader#" * ")//locate info after insert comments
    InsBufLine(hBuf, ln++, strHeader#" *")

    var index
    index = 0
    while(index < childrenInfo.count)
    {
        type = GGetStringBySeparateCh(childrenInfo.type, strSeparate, index)
        name = GGetStringBySeparateCh(childrenInfo.name, strSeparate, index)
        
        if(type == "FuncParam")
        {
            InsBufLine(hBuf, ln++, strHeader#" * @@param @name@	{ parameter_description }")//[in/out]
        }
        else if(type == "FuncType" && name != "void")
        {
            InsBufLine(hBuf, ln++, strHeader#" * @@return	{ description_of_the_return_value }")
            //InsBufLine(hBuf, ln++, strHeader#" * @@retval value description")//different style
        }
        ++index
    }


    InsBufLine(hBuf, ln++, strHeader#" *")
    InsBufLine(hBuf, ln++, strHeader#" * @@see")
    InsBufLine(hBuf, ln++, strHeader#" */")


    //locate the cursor
    SetBufIns(hBuf, locateLn, locateCur)
}




/*!
 *  Insert example codes after the cursor line with doxygen style in the block
 *comments.
 */
macro GDoxyInsExampleCodes()
{
    var hbuf
    hbuf = GetCurrentBuf()
    if(hbuf == hNil)
    {
        Msg("Current file handler is invalid.")
        stop
    }


    var lnCursor
    lnCursor = GetBufLnCur(hbuf)


    var strHead
    strHead = GGetHeaderSpaceByLn(hbuf, lnCursor)


    lnCursor++  ///<after the line of the cursor to insert the codes
    InsBufLine(hbuf, lnCursor++, strHead#"*")
    InsBufLine(hbuf, lnCursor++, strHead#"* @@code")


    ///reserve four line to insert example codes
    var locateLn
    var locateCol
    locateLn  = lnCursor
    locateCol = strlen(strHead#"*")
    InsBufLine(hbuf, lnCursor++, strHead#"*")
    InsBufLine(hbuf, lnCursor++, strHead#"*")
    InsBufLine(hbuf, lnCursor++, strHead#"*")
    InsBufLine(hbuf, lnCursor++, strHead#"*")


    InsBufLine(hbuf, lnCursor++, strHead#"* @@endcode")


    //locate cursor
    SetBufIns(hbuf, locateLn, locateCol)
}


/*!
 *Insert a doxygen common comments before the line of cursor.
 */
macro GDoxyInsBlockComment()
{
    var hbuf
    hbuf = GetCurrentBuf()
    if(hbuf == hnil)
    {
        msg("Current file handler is invalid.")
        stop
    }


    var lnCursor
    lnCursor = GetBufLnCur(hbuf)


    var strHeader
    var lnIter
    lnIter = lnCursor
    strHeader = GGetHeaderSpaceByLn(hbuf, lnCursor)


    InsBufLine(hbuf, lnIter++, strHeader#"/*!")
    InsBufLine(hbuf, lnIter++, strHeader#" *")
    InsBufLine(hbuf, lnIter++, strHeader#" *")
    InsBufLine(hbuf, lnIter++, strHeader#" */")


    SetBufIns(hbuf, lnCursor + 1, strlen(strHeader#" *"))
}


/*!
 *  Insert the doxygen style comments of enumeration.
 * @note
 *     Make sure the cursor in the enumeration region before call this macro.
 */
macro GDoxyEnumComment()
{
    var hbuf
    hbuf = GetCurrentBuf()
    if(hbuf == hNil)
    {
        Msg("Current file handler is invalid.")
        stop
    }


    var lnCursor
    lnCursor = GetBufLnCur(hbuf)


var eSymbol
    eSymbol = GGetEnumSymbol(hbuf, lnCursor)
    if(eSymbol == Nil)
    {
        Msg("The symbol at the cursor looks like not a enumeration.")
        stop
    }


    var strHeader
    var strTemp
    strHeader = GGetHeaderSpaceByLn(hbuf, eSymbol.lnFirst)


    //reset the symbol's first and last line text
    strTemp = GetBufLine(hbuf, eSymbol.lnFirst)
    idxSearch = GStrStr(strTemp, "{")
    strTemp = strmid(strTemp, 0, idxSearch + 1)
    PutBufLine(hbuf, eSymbol.lnFirst, strTemp)
    strTemp = GetBufLine(hbuf, eSymbol.lnLast)
    idxSearch = GStrStr(strTemp, "}")
    strTemp = strmid(strTemp, idxSearch, strlen(strTemp))
    PutBufLine(hbuf, eSymbol.lnLast, strTemp)


    //delete the lines text before
    var lnIter
    lnIter = eSymbol.lnLast - 1
    while(lnIter > eSymbol.lnFirst)
    {
        DelBufLine(hbuf, lnIter)
        lnIter--
    }


    //rewrite members and insert comments
    var nMembers
    nMembers = 0
    lnIter   = eSymbol.lnFirst + 1
    while(nMembers < eSymbol.count)
    {
        strTemp = GGetStringBySeparateCh(eSymbol.members, eSymbol.chSeparator, nMembers)
        if(!(GStrBeginWith(strTemp, "#if") || GStrBeginWith(strTemp, "#end") || GStrBeginWith("#else")))
        {
            strTemp = GStrAppendTailSpace(strTemp, eSymbol.maxMemberLen)
            strTemp = strHeader#"    "#strTemp#" ///!<"
        }
        InsBufLine(hbuf, lnIter, strTemp)


        nMembers++
        lnIter++
    }


    //locate cursor
    SetBufIns(hbuf, eSymbol.lnFirst + 1, strlen(strTemp))
}


///////////////////////////////////////////////////////////////////////////////
///  Tool macros under.These macros are offering service for the other macros.
///Note:It's not need to assign keys or menus for the macros under, even if you
///can do this operation.
///////////////////////////////////////////////////////////////////////////////


/*!
 *  Get the enumeration info,if the symbol at the cursor is not a enumeration,
 *it will return a Nil symbol recorder.
 *
 *construct an enumeration symbol recorder,it contains the fields:
 *  type         enum type name
 *  members      string of members which is separated by specail character, and the spaces will be deleted
 *  chSeparator  the separate character of members
 *  count        the number of the members
 *  lnFirst      symbol first line
 *  lnLast       symbol last line
 *  maxMemberLen the longest member's character number
 */
macro GGetEnumSymbol(hbuf, lnCursor)
{
    var eSymbol


var region
    region = GGetEnumRegion(hbuf, lnCursor)
    if(region == Nil)
    {//can't get enumeration symbol info
        return Nil
    }


    eSymbol.type        = nil
    eSymbol.members     = nil
    eSymbol.chSeparator = ";"
    eSymbol.count       = 0
    eSymbol.maxMemberLen= 0
    eSymbol.lnFirst     = region.first
    eSymbol.lnLast      = region.last


    //analysis codes
    var lenMember//the length of the enumeration's one member
    var lnIter   //line iterator from the enumeration's first line to the last
    var lnString //used to get the string text of one line
    var tempStr  //used to contains the member string
    var lenLnStr //the character num of the string of line
    var isComment//indicate whether need to skip the characters


    lnIter    = eSymbol.lnFirst
    isComment = false
    lenMember = 0
    while(lnIter <= eSymbol.lnLast)
    {
        tempStr  = nil
        lnString = Nil


        //get line text
    lnString = GetBufLine(hbuf, lnIter)
    lenLnStr = strlen(lnString)
    if(lenLnStr == 0)
    {
       lnIter++
       continue
    }


        //deal with the indicator
    lenLnStr = strlen(lnString)
    lIndicate= GStrStr(lnString, "{")
    if(lIndicate != invalid)
    {
       lIndicate++//skip "{" character
       lnString = strmid(lnString, lIndicate, lenLnStr)
    }
    rIndicate= GStrStr(lnString, "}")
    lenLnStr = strlen(lnString)
    if(rIndicate != invalid)
    {
            lnString = strmid(lnString, 0, rIndicate)
    }


        //prepare the pure string
    lnString = GStrTrimJustify(lnString)//GStrRemoveAllSpace(lnString)
    lenLnStr = strlen(lnString)
    if(lenLnStr == 0)
    {
       lnIter++
       continue
    }


        //analysising
    ich = 0
    while(ich < lenLnStr)
    {
            if(!isComment && lnString[ich] == "/" && lnString[ich+1] == "/")
            {//don't need to analysis the rest charaters in this line
                break
            }


            if(lnString[ich] == "/" && lnString[ich+1] == "*")
            {
                isComment = true
            }


            if(!isComment)
            {
                if(lnString[ich] == "," && tempStr != nil)
                {//it is possible that one line has several members
                    tempStr = GStrTrimJustify(tempStr)
                    tempStr = cat(tempStr, lnString[ich])
                    lenMember = strlen(tempStr)
                    if(lenMember != 0)
                    {
                        eSymbol.members = eSymbol.members#tempStr#";"
                        eSymbol.count   = eSymbol.count + 1
                        if(lenMember > eSymbol.maxMemberLen)
                        {
                            eSymbol.maxMemberLen = lenMember
                        }
                    }
                    tempStr = nil
                }
                else
                {
                    tempStr = cat(tempStr, lnString[ich])
                }
            }


            if(lnString[ich] == "*" && lnString[ich+1] == "/")
            {
                ich++
                isComment = false
            }
       ich++
    }


        tempStr = GStrTrimJustify(tempStr)
        lenMember = strlen(tempStr)
        if(lenMember != 0)
        {
            eSymbol.members = eSymbol.members#tempStr#";"
            eSymbol.count = eSymbol.count + 1
            if(lenMember > eSymbol.maxMemberLen)
            {
                eSymbol.maxMemberLen = lenMember
            }
        }


    lnIter++
    }


    return eSymbol
}


/*!
 *Get the enumeration region which contains the first line and last line.
 *The first line is the "{" appears line.
 *The last line is the "}" appears line.
 */
macro GGetEnumRegion(hbuf, lnCursor)
{
    //variables
    var region
    var tempStr
    var lnIter
    var iAppear
    var lnMax//file line count


    region  = Nil
    tempStr = Nil
    iAppear = invalid


    //first line
    lnIter  = lnCursor
    while(lnIter >= 0)
    {
        tempStr = GetBufLine(hbuf, lnIter)
        iAppear = GStrStr(tempStr, "{")
        if(iAppear != invalid)
        {
            region.first = lnIter
            break
        }
        lnIter--
    }


    if(lnIter < 0)
    {
        return Nil
    }


    //last line
    lnIter  = lnCursor
    iAppear = invalid
    lnMax   = GetBufLineCount(hbuf)
    while(lnIter < lnMax)
    {
        tempStr = GetBufLine(hbuf, lnIter)
        iAppear = GStrStr(tempStr, "}")
        if(iAppear != invalid)
        {
            region.last = lnIter
            break
        }
        lnIter++
    }


    if(lnIter == lnMax)
    {
        return Nil
    }


    return region
}


/*!
 *   Get a string from strParent which is separate by character.
 * @note
 *    The separate character that at the begining will be ignored.
 *
 *  Example 1:
 *    ch = ";"
 *    strParent = "first;second;third;"
 *    If index equals 0, it will return "first"
 *    If index equals 1, it will return "second"
 *    If index equals 2, it will return "third"
 *    If index equals 3, it will return ""
 *    ...
 *
 *  Example 2:
 *    ch = ";"
 *    strParent = ";first;second;third;"
 *    If index equals 0, it will return "first"
 *    If index equals 1, it will return "second"
 *    If index equals 2, it will return "third"
 *    ...
 */
macro GGetStringBySeparateCh(strParent, ch, index)
{
    /*variables*/
    var len
    var iChBeg
    var iChEnd
    var iLoop
    var countIdx
    var checkEndIdx


    /*codes*/
    len = strlen(strParent)
    if(0 == len)
    {
        return Nil
    }


    iChBeg = 0 //result begin index
    while(iChBeg < len)
    {//ignore all the characters ch that at the begin o strParent
        if(strParent[iChBeg] == ch)
        {
            iChBeg++
        }
        else
        {
            break
        }
    }
    iChEnd = iChBeg //result end index


    iLoop = iChBeg
    countIdx = 0
    checkEndIdx = False
    while(iLoop < len)
    {
        if(countIdx == index)
        {
            checkEndIdx = True
        }
        if(strParent[iLoop] == ch)
        {
            if(checkEndIdx)
            {//get end index
                iChEnd = iLoop
                break
            }
            else
            {//get begin index
                countIdx++
                iChBeg = iLoop + 1
            }
        }
        iLoop++
    }


    if(iChBeg == iChEnd)
    {
        if(index == 0)
        {
            return strParent
        }
        else
        {
            return Nil
        }
    }


    if(index != countIdx)
    {
        return Nil
    }


    return strmid(strParent, iChBeg, iChEnd)
}

/******************************************************************************
 * String macros definition
 *****************************************************************************/


/*!
 *   Insert spaces at the begining of string until the string's length reaches
 * lenMax.It will return string itself if the string's length is less then
 * lenMax.
 */
macro GStrInsertHeadSpace(string, lenMax)
{
    var len
    var nSpace
    var tempStr


    len    = strlen(string)
    nSpace = lenMax - len
    tempStr= nil
    while(nSpace > 0)
    {
        tempStr = cat(tempStr, " ")
        nSpace--
    }


    return cat(tempStr, string)
}


/*!
 *   Append spaces at the end of string until string's length reaches lenMax.It
 * will returns the string itself if the string's length is less then lenMax.
 */
macro GStrAppendTailSpace(string, lenMax)
{
    nStr = strlen(string)
    while(nStr < lenMax)
    {
        string = cat(string, " ")
        nStr++
    }


    return string
}


/*!
 *Test whether the string contains the character ch.
 */
macro GStrContainsCh(string, ch)
{
    var index
    index = GStrStr(string, ch)


    if(index == invalid)
    {
        return False
    }


    return True
}


/*!
 *  Returns the last place of appearance that the ch appears in string.
 *  If the ch is not appears in string, it will returns invalid(-1).
 */
macro GStrRFind(string, ch)
{
    var len
    var idx


    len = strlen(string)


    idx = len - 1
    while(idx >= 0)
    {
        if(string[idx] == ch)
        {
            break
        }
        idx--
    }


    return idx
}


/*!
 *   Test whether all the characters in the string are spaces.
 */
macro GStrAllSpace(string)
{
    len = strlen(string)
    iter = 0
    while(iter < len)
    {
        if(!GIsCharSpace(string[iter]))
        {
            return false
        }
        iter++
    }


    return true
}


/*!
 *Test if string is empty.
 * @param  string need to be tested string
 * @retval True   the string is empty
 * @retval False  the string is not empty
 */
macro GStrEmpty(string)
{
    var len


    len = strlen(string)
    if(len == 0)
    {
        return True
    }
    return False
}


/*!
 *Remove all the space and tab characters in the string.
 */
macro GStrRemoveAllSpace(string)
{
    var len
    var idx
    var str


    len = strlen(string)
    idx = 0
    str = Nil


    while(idx < len)
    {
        if(!GIsCharSpace(string[idx]))
        {
            str = cat(str, string[idx])
        }
        idx++
    }


    return str
}


/*!
 *Remove the space and tab characters at the begin and end of string.
 */
macro GStrTrimJustify(string)
{
    var len
    var index  //first not space character index
    var rIndex //last not space character index


    len = strlen(string)


    index = 0
    while(index < len)
    {
        if(GIsCharSpace(string[index]))
        {
            index++
        }
        else
        {
            break
        }
    }


    if(index == len)
    {
        return nil
    }


    rIndex = len - 1
    while(rIndex >= 0)
    {
        if(GIsCharSpace(string[rIndex]))
        {
            rIndex--
        }
        else
        {
            break
        }
    }


    rIndex++ //strmid function will not get the character at rIndex palce
    return strmid(string, index, rIndex)
}


/*!
 *   Remove the characters between the index iFirst and index iEnd from string.
 * The character at iFirst and iEnd will be deleted also.
 */
macro GStrRemoveStrByIndex(string, iFirst, iEnd)
{
    var len
    len = strlen(string)


    if(iFirst < 0 || iEnd < 0 || iEnd > len || iFirst > len || iEnd < iFirst)
    {
        return string
    }


    var temp
    temp = nil
    temp = strmid(string, 0, iFirst)
    temp = cat(temp, strmid(string, iEnd + 1, len))


    return temp
}


/*!
 *GStrStr
 *  Test whether the strTest is existing in strSrc.And returns
 *the place where the strTest first appears.Otherwise returns
 *-1.
 */
macro GStrStr(strSrc, strTest)
{
    var nSrc
    var nTest


    nSrc  = strlen(strSrc)
    nTest = strlen(strTest)


    if(nTest == 0)
    {
        return 0
    }
    else if(nSrc == 0)
    {
        return invalid
    }


    var iSrc
    var iTest
    iSrc  = 0
    iTest = 0
    while(iSrc < nSrc)
    {
        iTest = 0
        while(iTest < nTest)
        {
            if(strSrc[iSrc+iTest] == strTest[iTest])
            {
                iTest++
            }
            else
            {
                break
            }
        }
        if(iTest == nTest)
        {
            return iSrc
        }
        iSrc++
    }


    return invalid
}


/*!
 *GIsCharSpace
 *  Test whether the char ch is a space or a tab character.
 */
macro GIsCharSpace(ch)
{
    if(ch == Nil)
    {
        return False
    }


    if(AsciiFromChar(ch) == 9 || AsciiFromChar(ch) == 32)
    {
        return True
    }
    return False
}


/*!
 *Test whether the string is begin wiht string with.
 *note:
 *  it will ignore the first spaces
 */
macro GStrBeginWith(string, with)
{
string = GStrTrimJustify(string)
index  = GStrStr(string, with)


if(index == 0)
{
return true
}


return false
}






/******************************************************************************
 * File and buffer macros definition
 *****************************************************************************/


/*!
 *GGetHeaderSpaceByLn
 *  Get the spaces that at the begin of line in the hbuf file.
 *note
 *  Make sure the hbuf is a valid handler, and the line number is a
 *valid line for hbuf.
 */
macro GGetHeaderSpaceByLn(hbuf, line)
{
    var headSpace
    headSpace = ""


    var strContent
    var len
    strContent = GetBufLine(hbuf, line)
    len = strlen(strContent)


    var idx
    idx = 0
    while(idx < len)
    {
        if(GIsCharSpace(strContent[idx]))
        {
            headSpace = cat(headSpace, strContent[idx])
        }
        else
        {
            break
        }
        idx++
    }
    return headSpace
}


/*
 *GGetFileName
 *  Get file name from file full path.
 */
macro GGetFileName(fFullName)
{
    var nLength
    var fName


    nLength = strlen(fFullName)
    fName   = ""


    var i
    var ch
    i = nLength - 1
    while(i >= 0)
    {
        ch = fFullName[i]
        if("@ch@" == "\\")
        {
            i++ //don't take the '\' charater
            break
        }
        i--
    }
    fName = strmid(fFullName, i, nLength)
    return fName
}






/******************************************************************************
 * Symbol macros definition
 *****************************************************************************/


/*!
 *  If we get the symbol name by symbolrecord.Symbol, we will get the string
 *like class.func, func.void, et.This function will get the last one name that
 *seperate by ".".
 *  @param[in] symbol is the Symbol Record's Symbol field
 *note
 *  see Symbol Record of SI macro language
 */
macro GGetSymExactName(symbol)
{
    var len
    var idxAppear
    var strRet


    len = strlen(symbol)
    idxAppear = GStrRFind(symbol, ".")


    if(idxAppear == invalid)
    {//can't get the expectant name, return the default one
        return symbol
    }


    idxAppear++
    strRet = strmid(symbol, idxAppear, len)
    return strRet
}

    在??的?程中，??SI?本中?有??的功能，但是又?常需要用到??的功能，所以?了几?方法，?模仿??：
/******************************************************************************
 * self-defining array macros definition
 *
 *Note the under ideas:
 *  1.Since the source insight macro language is only support string variable,
 *so the array is implemented as string.
 *  2.The array string looks like string "item1;item2;item3".And the separator
 *character is ";" which can be specified by yourself.
 *  3.The array index is begin with 0.And the separator can't be a string, it
 *only can contains one character.
 *  4.The item can be a empty string, such as set array like this "item1;;item3",
 *and the second item is a empty string.
 *  5.When using this array type, please reset the array value when the array
 *changed no matter whatever the operation is.Because the source insight don't
 *support the output parameter.
 *  6.If you assign the array string by yourself, please make sure the end
 *character is separator.
 *  7.The character separator is not a part of item string.And it must be not
 *empty.Don't set it as the character that source insight not support in string.
 *****************************************************************************/




/*!
 *   Append an item at the back.If the separator is empty, it will do nothing.
 *   Returns the new array string.
 *
 * @code
 *   item = "itemN"
 *   separator = "?"
 *   array = GArrayAppendItem(array, item, separator)
 * @endcode
 */
macro GArrayAppendItem(array, item, separator)
{
    if(GStrEmpty(separator))
    {//separator is needed even though the arry or item is empty
        return array
    }


    return array#item#separator
}


/*!
 *   Insert an item at index place, and after this operation, the item at the
 * index will be the inserted item.
 *   If the index is larger then the array's count,the item will not be appended.
 *   If the index is a negative number or the separator is empty, this macro
 * will do nothing.
 *   Returns the new array string.
 */
macro GArrayInsertItem(array, index, item, separator)
{
    if(index < 0 || GStrEmpty(separator))
    {
        return array
    }


    var cItem
    var len
    var iter
    var iInsert
    iter    = 0
    len     = strlen(array)
    cItem   = 0
    iInsert = 0
    while(iter < len)
    {
        if(cItem == index)
        {
            iInsert = iter
            break
        }
        if(array[iter] == separator)
        {
            cItem++
        }
        iter++
    }


    if(iter == len && cItem <= index)
    {
        return GArrayAppendItem(array, item, separator)
    }


    return cat(strmid(array, 0, iInsert)#item#separator, strmid(array, iInsert, len))
}


/*!
 *   Returns the count of array.That is the array's items num.It will returns
 * an error if the separator is empty.
 */
macro GArrayGetCount(array, separator)
{
    if(GStrEmpty(separator))
    {
        return invalid
    }


    var count
    var len


    count = 0
    len = strlen(array)
    if(len == 0)
    {
        return count
    }


    var ich
    ich = 0
    while(ich < len)
    {
        if(array[ich] == separator)
        {
            count++
        }
        ich++
    }


    return count
}


/*!
 *   Remove the items that is referened by item string from array and returns
 * the new array string.
 *   It will do nothing if the item is not in the array.If item string appears
 * not one time in array it will revome all the item string from array.
 */
macro GArrayRemoveItemByItem(array, item, separator)
{
    if(GStrEmpty(separator))
    {
        return array
    }


    var iter
    var itemIter //one item string
    var len
    var itemIdx//current item index
    var nArray //new array string


    iter    = 0
    itemIdx = -1
    len     = strlen(array)
    nArray  = nil
    iBegin  = 0 //current item start index
    while(iter < len)
    {
        if(array[iter] == separator)
        {
            iEnd = iter //set current item end index
            itemIdx++


            itemIter = strmid(array, iBegin, iEnd)


            if(itemIter != item)
            {
                nArray = cat(nArray, itemIter#separator)
            }
            iBegin = iter + 1
        }
        iter++
    }


    return nArray
}


/*!
 *   Remove an item that is at the index of array.It will do nothing if the
 * index is larger then the array's count.
 *   Returns the new array string.
 */
macro GArrayRemoveItemByIndex(array, index, separator)
{
    if(index < 0 || GStrEmpty(separator))
    {
        return array
    }


    var iter      //character iterator of array
    var itemStart //the index item string's start character index
    var itemEnd   //the index item string's end character index
    var cItem     //indicates the current item index that is dealing with
    var len       //character num of array


    itemStart = 0
    itemEnd   = invalid
    iter      = 0
    cItem     = -1
    len       = strlen(array)
    while(iter < len)
    {
        if(array[iter] == separator)
        {
            cItem++
            if(cItem == index)
            {
                itemEnd = iter + 1
            }
            else
            {
                itemStart = iter + 1
            }
        }
        if(itemEnd != invalid)
        {
            break
        }
        iter++
    }


    if(itemEnd == invalid)
    {
        return array
    }


    return cat(strmid(array, 0, itemStart), strmid(array, itemEnd, len))
}


/*!
 *    Get the index item from array.It will returns an empty string if the index
 * is larger then the array's count or the item at index is empty.
 *    Returns the item string at index.
 */
macro GArrayGetItemByIndex(array, index, separator)
{
    if(index < 0 || GStrEmpty(separator))
    {
        return nil
    }


    var item
    var iter
    var cItem
    var len


    item   = nil
    iter   = 0
    len    = strlen(array)
    cItem  = -1 //It starts at 0
    while(iter < len)
    {
        if(array[iter] == separator)
        {
            cItem++
            if(cItem == index)
            {
                break
            }
            item = nil
        }
        else
        {
            item = cat(item, array[iter])
        }
        iter++
    }


    return item
}


/*!
 *    Get the index of the item.It will returns -1 if the item is not in the
 * array.It will only get the index of the item that first appears in array if
 * the item is not a only one.
 *    If the separator is empty it will return -1.
 */
macro GArrayGetItemIndex(array, item, separator)
{
    if(GStrEmpty(separator))
    {
        return invalid
    }


    var iter
    var len
    var itemIdx//current item index


    iter    = 0
    itemIdx = -1
    len     = strlen(array)
    iBegin  = 0 //current item start index
    while(iter < len)
    {
        if(array[iter] == separator)
        {
            iEnd = iter //set current item end index
            itemIdx++


            if(strmid(array, iBegin, iEnd) == item)
            {
                return itemIdx
            }
            else
            {
                iBegin = iter + 1
            }
        }
        iter++
    }


    return invalid
}


/*!
 *   Check whether the item is in the array.
 *   If the separator is empty, it will always returns false.
 */
macro GArrayIsItemExist(array, item, separator)
{
    if(GStrEmpty(separator))
    {
        return false
    }
    else
    {
        if(GArrayGetItemIndex(array, item, separator) != invalid)
        {
            return true
        }
    }


    return false
}