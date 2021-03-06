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
		catch (Exception e)
		{
			System.out.println("Something went wrong! Try reloading the page.");
			return;
		}
	}
%>
<%
	if(session.getAttribute(Attribute.USERID)==null){
		response.sendRedirect("login.jsp");
		return;
	}

	long uid = (Long) session.getAttribute(Attribute.USERID);
	
	if (session.getAttribute(Attribute.DOCTYPE) == null) {
		response.sendRedirect("landing.jsp");
		return;
	}
	DocumentType dt = (DocumentType) session.getAttribute(Attribute.DOCTYPE);
	
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
			// Already voted
		}
	}
%>

</head>
<body>

      <!-- The page -->
      <div class="page">
         <div class="header">
            <a href="#menu"></a>
            Search
         </div>
         <div class="content" style="padding-top:10px;">


		<form id="tfnewsearch" method="get" action="results.jsp">
		        <input type="text" name="query" size="21" maxlength="120"><input type="submit" value="search">
		</form>

<%

	String searchQuery = request.getParameter("query");
	if (searchQuery == null) searchQuery = "";
	String searchDomain = request.getParameter("domain"); //tag, document or user.
	if (searchDomain == null) searchDomain = "documents";
	if (!searchDomain.equals("documents") && !searchDomain.equals("tags") && !searchDomain.equals("users") ) searchDomain = "documents";
%>
	<div id="searchTypesHolder">
		<div class="searchType"><a href='<%="results.jsp?query=" + searchQuery + "&domain=documents"%>'>Documents</a></div>
		<div class="searchType"><a href='<%="results.jsp?query=" + searchQuery + "&domain=users"%>'>Users</a></div>
		<div class="searchType"><a href='<%="results.jsp?query=" + searchQuery + "&domain=tags"%>'>Tags</a></div>
	</div>
	<br>
	
<%
	if (searchQuery == null || searchQuery.length() == 0) 
	{
		out.println("<p class='error'>Enter a search string.</p>");
		
	}
	
	else
	{
		out.println("<p id='query'>Searching " + searchDomain + " for '" + searchQuery + "'</p>");
		%><table><%
	
		if (searchDomain.equals("documents"))
		{
			//TODO: query Document database for matching titles
			QueryParam p = new QueryParam(25, 0, QueryParam.SortField.VOTES, QueryParam.SortOrder.DESCENDING);
			ArrayList<PublishedDocument> matchingDocs = (ArrayList<PublishedDocument>) DocumentManager.getInstance().getPublishedByTitle(searchQuery, dt, p);
					
			User thisUser = LoginManager.getInstance().getUser(uid);
			ArrayList<Long> upvotedDocuments = (ArrayList<Long>) dm.hasUpvoted(thisUser, matchingDocs);
			
			for (PublishedDocument pd : matchingDocs)
			{
	
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
				String upvoteLink = "<a href='results.jsp?query=" + HTMLEncoder.encode(searchQuery) + "&domain=" + searchDomain + "&upvote=" + Long.toString(pd.getID()) + "'>";
				String upvoteEndLink = "</a>";
				String upvoteImage = "UpvoteNormal.png";
				if (upvotedDocuments.contains(pd.getID())) {
					upvoteImage = "UpvoteEngaged.png";
					upvoteLink = "";
					upvoteEndLink = "";
				}
				String entry = 
				"<tr class='upperRow'>" + 
				"<td class='upvote'>" + upvoteLink + " <img src='" + upvoteImage + "'>"+upvoteEndLink+"</td>" + //upvote
				"<td class='title'> <a href='preview.jsp?docID=" + Long.toString(pd.getID()) + "'>" + HTMLEncoder.encode(pd.getTitle()) 		+ "</a></td>" + //title
				"<td class='age'>" + ageString + "</td>" + //age
				"</tr>" + 
				"<tr class='lowerRow'>" +
				"<td id='score" + Long.toString(pd.getID()) + "' class='votes'>" + pd.getVotes()	+ "</td>" + //score
				"<td class='submitter'> <a href='profile.jsp?id=" + Long.toString(pd.owner.getID()) + "'>" + HTMLEncoder.encode(pd.owner.getName()) 		+ "</a></td>" + //submitter
				"<td></td>" +
				"</tr>"; 
				
				out.println(entry);
			} 
			
		}
		
		else if (searchDomain.equals("users"))
		{
			//TODO: maybe implement a fuzzier search here?
				try
				{
					User u = LoginManager.getInstance().getUser(searchQuery);
					String userID = Long.toString(u.getID());
					out.println(userID);
					out.println("<a class='searchResult' href='profile.jsp?id=" + userID + "'>" + HTMLEncoder.encode(u.getName()) + "</a>");		
				}
				catch (Exception e)
				{
					out.println("No such user exists.");
				}
	
		
		}
		
		else if (searchDomain.equals("tags"))
		{
			//TODO: query Tag database for matching names
				try
				{
					Tag tag = DocumentManager.getInstance().getTag(searchQuery);
					String tagID = tag.name;
					out.println("<a class='searchResult' href='tag.jsp?name=" + HTMLEncoder.encode(tagID) + "'>" + HTMLEncoder.encode(tag.name) + "</a>");		
				}
				catch (Exception e)
				{
					out.println("No such tag exists.");
				}
	
		}
	}
%>
</table>

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