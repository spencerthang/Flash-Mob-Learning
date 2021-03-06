package uk.ac.cam.grpproj.lima.flashmoblearning.database;

import junit.framework.Assert;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import uk.ac.cam.grpproj.lima.flashmoblearning.Student;
import uk.ac.cam.grpproj.lima.flashmoblearning.Teacher;
import uk.ac.cam.grpproj.lima.flashmoblearning.TestHelper;
import uk.ac.cam.grpproj.lima.flashmoblearning.User;
import uk.ac.cam.grpproj.lima.flashmoblearning.database.exception.DuplicateEntryException;
import uk.ac.cam.grpproj.lima.flashmoblearning.database.exception.NoSuchObjectException;

import javax.management.Query;
import java.lang.reflect.Field;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Connection;
import java.util.List;

public class LoginManagerTests {

    private static final String c_TestUsername = "loginmanager_test";
    private static final String c_TestPassword = "test_password";
    private int m_UserID;
    private Statement m_Statement;
    private Connection m_Connection;

    @Before
    public void setUp() throws Exception {
        TestHelper.databaseInit();
        m_Statement = Database.getInstance().getStatement();
        m_Connection = Database.getInstance().getConnection();

        // Create a test user
        m_Statement.executeUpdate("DELETE FROM users WHERE username = '" + c_TestUsername + "'");
        PreparedStatement ps = m_Connection.prepareStatement("INSERT INTO users (username, password, teacher_flag) VALUES (?, ?, 0)", Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, c_TestUsername);
        ps.setString(2, c_TestPassword);
        ps.executeUpdate();

        ResultSet rs = ps.getGeneratedKeys(); rs.next();
        m_UserID = rs.getInt(1);
    }

    @After
    public void tearDown() throws Exception {
        TestHelper.databaseCleanTablesAndClose();
    }

    @Test
    public void testIsInitialized() throws Exception {
        LoginManager m = LoginManager.getInstance();
        // exception should be thrown above if it's not initialized.
    }

    @Test
    // Tests both the fact that we can get the user, and that the user in setup has been created.
    public void testGetUser() throws Exception {
        Student student = (Student) LoginManager.getInstance().getUser(c_TestUsername);
        Assert.assertEquals("User retrieved", c_TestUsername, student.getName());
    }

    @Test
    public void testGetAllUsers() throws Exception {
        List<User> users = LoginManager.getInstance().getAllUsers(QueryParam.UNSORTED);
        Assert.assertTrue("1 or more users retrieved", users.size() >= 1);
    }

    @Test
    public void testGetUserById() throws Exception {
        Student student = (Student) LoginManager.getInstance().getUser(m_UserID);
        Assert.assertEquals("User retrieved", c_TestUsername, student.getName());
    }

    @Test
    public void testUpdateTeacher() throws Exception {
        User u = LoginManager.getInstance().getUser(c_TestUsername);
        Teacher t = new Teacher(u.getID(), u.getName(), u.getEncryptedPassword());
        LoginManager.getInstance().modifyUser(t);

        Teacher u2 = (Teacher) LoginManager.getInstance().getUser(c_TestUsername);
    }

    @Test(expected=DuplicateEntryException.class)
    public void testAddExistingUser() throws Exception {
        LoginManager.getInstance().createUser(c_TestUsername, c_TestPassword, true);
    }

    @Test(expected=NoSuchObjectException.class)
    public void testGetNonexistentUser() throws Exception {
        User u = LoginManager.getInstance().getUser("user_which_does_not_exist");
    }

    @Test(expected=NoSuchObjectException.class)
    public void testDeleteUser() throws Exception {
        User u = LoginManager.getInstance().getUser(c_TestUsername);
        LoginManager.getInstance().deleteUser(u);

        // Trying to get this user should return a NoSuchObjectException
        LoginManager.getInstance().getUser(c_TestUsername);
    }

    @Test
    public void testModifyUserPassword() throws Exception {
        User u = LoginManager.getInstance().getUser(c_TestUsername);
        // Use reflection to modify encryptedPassword.
        Field field = User.class.getDeclaredField("encryptedPassword");
        field.setAccessible(true);
        field.set(u, c_TestPassword + "_new");
        LoginManager.getInstance().modifyUser(u);

        User u2 = LoginManager.getInstance().getUser(c_TestUsername);
        Assert.assertEquals("Password changed", c_TestPassword + "_new", field.get(u2));
    }

    @Test
    public void testSetAndGetLoginBanner() throws Exception {
        String original = LoginManager.getInstance().getLoginBanner();

        // Perform the actual test.
        String test_banner = "This is a test banner.";
        LoginManager.getInstance().setLoginBanner(test_banner);
        Assert.assertEquals("Test banner updated.", test_banner, LoginManager.getInstance().getLoginBanner());

        // Restore the original banner (if any)
        LoginManager.getInstance().setLoginBanner(original);
    }
}