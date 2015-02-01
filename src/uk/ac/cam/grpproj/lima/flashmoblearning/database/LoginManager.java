package uk.ac.cam.grpproj.lima.flashmoblearning.database;

import uk.ac.cam.grpproj.lima.flashmoblearning.User;
import uk.ac.cam.grpproj.lima.flashmoblearning.database.exception.DuplicateNameException;
import uk.ac.cam.grpproj.lima.flashmoblearning.database.exception.NoSuchObjectException;
import uk.ac.cam.grpproj.lima.flashmoblearning.database.exception.NotInitializedException;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class LoginManager {

	private Database m_Database;

	protected LoginManager(Database database) {
		m_Database = database;
	}

	public static LoginManager getInstance() throws NotInitializedException {
		return Database.getInstance().getLoginManager();
	}
	
	/** Get a user by username */
	public User getUser(String username) throws SQLException, NoSuchObjectException {
		PreparedStatement ps = m_Database.getConnection().prepareStatement("SELECT * FROM users WHERE username = ?");
		ps.setString(1, username);
		ResultSet rs = ps.executeQuery();

		if(!rs.next()) throw new NoSuchObjectException();
		return new User(rs.getInt("id"), rs.getString("username"), rs.getString("password"));
	}
	
	/** Delete a user by username */
	public void deleteUser(User user) throws SQLException, NoSuchObjectException {
		PreparedStatement ps = m_Database.getConnection().prepareStatement("DELETE FROM users WHERE id = ?");
		ps.setLong(1, user.getID());

		int affected_rows = ps.executeUpdate();
		if(affected_rows < 1) throw new NoSuchObjectException();
	}
	
	/** Create a user */
	public User createUser(String username, String saltedPassword) throws SQLException, DuplicateNameException {
		PreparedStatement ps = m_Database.getConnection().prepareStatement("INSERT INTO users (`username`, `password`, `teacher_flag`) VALUES (?, ?, 0)");
		ps.setString(1, username);
		ps.setString(2, saltedPassword);

		// Catch any duplicate name exceptions and throw our own.
		try {
			ps.executeUpdate();
		} catch (SQLException e) {
			if(e.getMessage().toLowerCase().contains("duplicate")) throw new DuplicateNameException();
			else throw e;
		}

		try {
			return getUser(username);
		} catch (NoSuchObjectException e) {
			// clearly, the creation failed!
			throw new SQLException("Failed to retrieve newly-created user - database error!");
		}
	}
	
	/** Modify a user, index by userId. */
	// TODO: Teacher flag!
	public void modifyUser(User u) throws SQLException, NoSuchObjectException, DuplicateNameException {
		PreparedStatement ps = m_Database.getConnection().prepareStatement("UPDATE users SET username = ?, password = ?, teacher_flag = ? WHERE id = ? LIMIT 1");
		ps.setString(1, u.name);
		ps.setString(2, u.getEncryptedPassword());
		ps.setBoolean(3, false); // TODO
		ps.setLong(4, u.getID());

		int affected_rows = ps.executeUpdate();
		if(affected_rows < 1) throw new NoSuchObjectException();
	}

	/** Get the login banner */
	public String getLoginBanner() throws SQLException, NoSuchObjectException {
		ResultSet rs = m_Database.getStatement().executeQuery("SELECT * FROM settings WHERE setting_name = 'login_banner'");
		if(!rs.next()) throw new SQLException("Login banner does not exist - database corrupt.");

		return rs.getString("setting_value");
	}

	/** Set the login banner */
	public void setLoginBanner(String banner) throws SQLException {
		PreparedStatement ps = m_Database.getConnection().prepareStatement("UPDATE settings SET setting_value = ? WHERE setting_name = 'login_banner' LIMIT 1");
		ps.setString(1, banner);
		ps.executeUpdate();
	}
}
