<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="java.sql.*, java.util.ArrayList, uk.ac.cam.grpproj.lima.flashmoblearning.*, uk.ac.cam.grpproj.lima.flashmoblearning.database.*, uk.ac.cam.grpproj.lima.flashmoblearning.database.exception.*" %>

<!DOCTYPE html>
<html>
   <head>

      <title>Flash Mob Learning</title>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <link type="text/css" href="css/demo.css" rel="stylesheet" />

      <!-- Include jQuery.mmenu .css files -->
      <link type="text/css" href="css/jquery.mmenu.all.css" rel="stylesheet" />

      <!-- Include jQuery and the jQuery.mmenu .js files -->
      <script type="text/javascript" src="jquery-2.1.3.min.js"></script>
      <script type="text/javascript" src="jquery.mmenu.min.all.js"></script>

      <!-- Fire the plugin onDocumentReady -->
      <script type="text/javascript">
         $(document).ready(function() {
            $("#menu").mmenu({
               "slidingSubmenus": false,
               "classes": "mm-white",
               "searchfield": true
            });
         });
      </script>
      <link rel="stylesheet" type="text/css" href="css/HubStyle.css">
<%!
 	public void jspInit()
	{
		try
		{
			Database.init();
		}
		
		catch (ClassNotFoundException e)
		{
			e.printStackTrace();
		}
		
		catch (SQLException e)
		{
			e.printStackTrace();
		}

	} 
%>


<%
	if(session.getAttribute(Attribute.USERID)==null){
		response.sendRedirect("login.jsp");
		return;
	}
	
	long uid = (Long) session.getAttribute(Attribute.USERID);

	long userID = 0;
	String userIDString = request.getParameter("id");
	if(userIDString==null){
		response.sendRedirect("error.jsp");
		return;
	}
	
	DocumentManager dm = DocumentManager.getInstance();

	String upvoted = request.getParameter("upvote"); //specifies which document to upvote
	if (upvoted != null)
	{
		long thisDocumentID = Long.parseLong(upvoted);
		User thisUser = LoginManager.getInstance().getUser(uid);
		

		PublishedDocument thisDocument = (PublishedDocument) dm.getDocumentById(thisDocumentID);
		
		try
		{
			dm.addVote(thisUser, thisDocument);
		}
		catch (DuplicateEntryException e)
		{
			// Already voted.
		}
	}
	
	DocumentType dt = DocumentType.ALL;
	if (request.getParameter("doctype")!=null) {
		String doctype = request.getParameter("doctype");
		if (doctype.equals("plaintext"))session.setAttribute(Attribute.DOCTYPE, DocumentType.PLAINTEXT);
		else if (doctype.equals("skulpt"))session.setAttribute(Attribute.DOCTYPE, DocumentType.SKULPT);
	}
	if (session.getAttribute(Attribute.DOCTYPE) == null) response.sendRedirect("landing.jsp");
	else dt = (DocumentType) session.getAttribute(Attribute.DOCTYPE); //browsing text or skulpt?
	
	String sortType = request.getParameter("sort");
	if (sortType == null ) sortType = "new";
	if (!sortType.equals("new") && !sortType.equals("top")) sortType = "new";
	String capitalisedSortType = sortType.substring(0, 1).toUpperCase() + sortType.substring(1);
	String pageNumberString = request.getParameter("page");
	if (pageNumberString == null) pageNumberString = "1";
	int pageNumber = Integer.parseInt(pageNumberString);
	int previousPage = pageNumber - 1;
	int nextPage = pageNumber + 1;
	if (pageNumber <= 1)
	{
		pageNumber = 1;
		previousPage = 1;
	}
	int limit = 25;
	int offset = (pageNumber - 1) * limit;
	
	try
	{
		userID = Long.parseLong(userIDString);	
	}
	catch (NumberFormatException e)
	{
		out.println("<p class='error'>This user ID is invalid!</p>");
		return;
	}
	
	ArrayList<PublishedDocument> thisUserDocuments = null;
	User profileUser;

	try
	{
		profileUser = LoginManager.getInstance().getUser(userID);
		QueryParam p;
		if (sortType.equals("new"))
		{
			p = new QueryParam(limit + 1, offset, QueryParam.SortField.TIME, QueryParam.SortOrder.DESCENDING);
		}
		
		else
		{
			p = new QueryParam(limit + 1, offset, QueryParam.SortField.VOTES, QueryParam.SortOrder.DESCENDING);
		}

		thisUserDocuments = (ArrayList<PublishedDocument>) DocumentManager.getInstance().getPublishedByUser(profileUser, dt, p);
	}
	
	catch (Exception e)
	{
		out.println("<p class='error'>This user doesn't seem to exist!</p>");
		e.printStackTrace();
		return;
	}
	
	
%>
   </head>
   <body>

      <!-- The page -->
      <div class="page">
         <div class="header">
            <a href="#menu"></a>
            Profile - <%= HTMLEncoder.encode(profileUser.getName()) %>
         </div>
         <div class="content" style="padding-top:10px;">
</head>
<body>
<%
	if(session.getAttribute(Attribute.USERID)==null){
		response.sendRedirect("landing.jsp");
		return;
	}

%>


      <!-- The page -->
      <div class="page">

         <div class="content" style="padding-top:10px;">

	<div id="orderHolder">
		<div id="inner">
			<div class="order" id="left"><a href='<%="profile.jsp?id=" + userIDString + "&sort=top"%>'>Top</a></div>
			<div class="order" id="right"><a href='<%="profile.jsp?id=" + userIDString + "&sort=new"%>'>New</a></div>
		</div>
	</div>

	<style>
		#inner{width:200px; display:block; margin:0 auto;}
		.order{float:left; padding-right:6%; width:50px}		
	</style>
	

<h2><%= capitalisedSortType %> Documents</h2>
<table>
<%
	User thisUser = LoginManager.getInstance().getUser(uid);
	ArrayList<Long> upvotedDocuments = (ArrayList<Long>) dm.hasUpvoted(thisUser, thisUserDocuments);
	
	for (int i = 0; i < Math.min(thisUserDocuments.size(),limit); i++)
	{
		PublishedDocument pd = thisUserDocuments.get(i);
		String ageString;
		int ageInHours = (int) ((System.currentTimeMillis() - pd.creationTime)/3600000);
		if (ageInHours < 1) ageString = "Less than an hour ago";
		else if (ageInHours < 2) ageString = "An hour ago";
		else if (ageInHours < 24) ageString = ageInHours + " hours ago";
		else
		{
			int ageInDays = ageInHours / 24;
			if (ageInDays == 1) ageString = "yesterday";
			else ageString = ageInDays + " days ago";
		}
		
		String upvoteLink = "<a href='profile.jsp?page=" + pageNumber + "&id=" + userIDString + "&sort=" + sortType + "&upvote=" + Long.toString(pd.getID()) + "'>";
		String upvoteImage = "UpvoteNormal.png";
		if (upvotedDocuments.contains(pd.getID())) upvoteImage = "UpvoteEngaged.png";
		String entry = 
		"<tr class='upperRow'>" + 
		"<td class='upvote'>" + upvoteLink + " <img src='" + upvoteImage + "'></a></td>" + //upvote
		"<td class='title'> <a href="+(dt==DocumentType.SKULPT?"'editor.jsp":"'preview.jsp")+"?docID=" + Long.toString(pd.getID()) + "'>" + HTMLEncoder.encode(pd.getTitle()) 		+ "</a></td>" + //title
		"<td class='age'>" + ageString + "</td>" + //age
		"</tr>" + 
		"<tr class='lowerRow'>" +
		"<td id='score" + Long.toString(pd.getID()) + "' class='votes'>" + pd.getVotes()	+ "</td>" + //score
		"<td></td>" + 
		"<td></td>" +
		"</tr>"; 
		
		out.println(entry);
	}
	
		String previousURL = "profile.jsp?sort=" + sortType + "&id=" + userIDString +  "&page=" + previousPage;
		String nextURL = "profile.jsp?sort=" + sortType + "&id=" + userIDString +  "&page=" + nextPage;
		
	%>

</table>
	<script>
	$(window).bind("load", function() { 
	    
	    var footerHeight = 0,
	        footerTop = 0,
	        $footer = $("#footer");
	        
	    positionFooter();
	    
	    function positionFooter() {
	    
	             footerHeight = $footer.height();
	             footerTop = ($(window).scrollTop()+$(window).height()-footerHeight)+"px";
	    
	            if ( ($(document.body).height()+footerHeight) < $(window).height()) {
	                $footer.css({
	                     position: "absolute"
	                }).animate({
	                     top: footerTop
	                })
	            } else {
	                $footer.css({
	                     position: "static"
	                })
	            }
	            
	    }
	
	    $(window)
	            .scroll(positionFooter)
	            .resize(positionFooter)
	            
	});
	</script>
	<div class="footer fixed"  >	
		<div id="inner">
		<%
			if (pageNumber != 1){
				%><div id="previousLink" class="footerElem"><a href='<%=previousURL %>'>Previous</a></div><%
			}else{
				%><div id="previousLink" class="footerElem">Previous</div><%;
			}
			%><div id="pageNumber" class="footerElem">Page <%=pageNumber %></div><%
			if (thisUserDocuments.size()==limit+1){
				%><div id="nextLink" class="footerElem"><a href='<%=nextURL %>'>Next</a></div><%
			}else{
				%><div id="nextLink" class="footerElem">Next</div><%;
			}%>
		</div>
	</div>		
	<style>
		
		#footer { height: 100px}	
		#inner{width:200px; display:block; margin:0 auto;}
		.footerElem{float:left; padding-right:3%}
	</style>
         </div>
      </div>


      <!-- The menu -->
      <nav id="menu">
         <ul>
            <li><a href="landing.jsp">Home</a></li>
            <li><a href="CreateNew.jsp?doctype=<%=(dt==DocumentType.SKULPT?"skulpt":"plaintext")%>">New Document</a></li>
            <li><a href="library.jsp">Library</a></li>
            <li><a href="profile.jsp?id=<%=uid%>">My Published Docs</a></li>
            <li><a href="hub.jsp">Community Hub</a></li>
            <li><a href="results.jsp">Search</a></li>
            <li style="padding-top: 140%;"></li>
            <li><a href="logout.jsp">Logout</a></li>
         </ul>
      </nav>

   </body>
</html>