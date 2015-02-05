package uk.ac.cam.grpproj.lima.flashmoblearning;

import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import junit.framework.Assert;

import org.junit.Test;

import uk.ac.cam.grpproj.lima.flashmoblearning.database.Database;
import uk.ac.cam.grpproj.lima.flashmoblearning.database.DocumentManager;
import uk.ac.cam.grpproj.lima.flashmoblearning.database.LoginManager;
import uk.ac.cam.grpproj.lima.flashmoblearning.database.QueryParam;
import uk.ac.cam.grpproj.lima.flashmoblearning.database.exception.NoSuchObjectException;
import uk.ac.cam.grpproj.lima.flashmoblearning.database.exception.NotInitializedException;

public class RevisionTest {
	
	final DocumentType docType = DocumentType.PLAINTEXT;
	private User owner;
	final String titleSimple = "Test document";
	final String payloadSimple = "Test payload";
	final String payloadUnicode = "Test "+((char)0x22A8)+" correct";
	
    @org.junit.Before
    public void setUp() throws Exception {
    	Database.init();
    	owner = LoginManager.getInstance().getUser(Database.DEFAULT_TEACHER_USERNAME);
    }

    @org.junit.After
    public void tearDown() throws Exception {
        Database.getInstance().close();
    }

	@Test
	public void testRevision() throws NotInitializedException, SQLException, IDAlreadySetException, NoSuchObjectException {
		WIPDocument doc = new WIPDocument(-1, docType, owner, titleSimple, System.currentTimeMillis());
		DocumentManager.getInstance().createDocument(doc);
		Revision r = Revision.createRevision(doc, new Date(), payloadSimple);
		Assert.assertNotSame(r.getID(), -1);
		Assert.assertEquals(r, doc.getLastRevision());
		List<Revision> revisions = doc.getRevisions(QueryParam.UNSORTED);
		Assert.assertEquals(1, revisions.size());
		Assert.assertEquals(r, revisions.get(0));
	}

	@Test
	public void testRevisionUnicode() throws NotInitializedException, SQLException, IDAlreadySetException, NoSuchObjectException {
		WIPDocument doc = new WIPDocument(-1, docType, owner, titleSimple, System.currentTimeMillis());
		DocumentManager.getInstance().createDocument(doc);
		Revision r = Revision.createRevision(doc, new Date(), payloadUnicode);
		Assert.assertNotSame(r.getID(), -1);
		Assert.assertEquals(r, doc.getLastRevision());
		List<Revision> revisions = doc.getRevisions(QueryParam.UNSORTED);
		Assert.assertEquals(1, revisions.size());
		Assert.assertEquals(r, revisions.get(0));
	}
	
	@Test
	public void testRevisions() throws NotInitializedException, SQLException, IDAlreadySetException, NoSuchObjectException, InterruptedException {
		WIPDocument doc = new WIPDocument(-1, docType, owner, titleSimple, System.currentTimeMillis());
		DocumentManager.getInstance().createDocument(doc);
		Revision r = Revision.createRevision(doc, new Date(), payloadSimple);
		Assert.assertNotSame(r.getID(), -1);
		Assert.assertEquals(r, doc.getLastRevision());
		List<Revision> revisions = doc.getRevisions(QueryParam.UNSORTED);
		Assert.assertEquals(1, revisions.size());
		Assert.assertEquals(r, revisions.get(0));
		Thread.sleep(21); // Make sure Date is different.
		Revision r2 = Revision.createRevision(doc, new Date(), payloadUnicode);
		Assert.assertEquals(r2, doc.getLastRevision());
		revisions = doc.getRevisions(new QueryParam(10, 0, QueryParam.SortField.TIME, QueryParam.SortOrder.ASCENDING));
		Assert.assertEquals(2, revisions.size());
		Assert.assertEquals(r, revisions.get(0));
		Assert.assertEquals(r2, revisions.get(1));
	}
	
	// FIXME PublishedDocument's.
	// FIXME forking - different Revision

}