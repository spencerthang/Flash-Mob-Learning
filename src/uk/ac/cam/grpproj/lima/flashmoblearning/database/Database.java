package uk.ac.cam.grpproj.lima.flashmoblearning.database;

/** Singleton class which opens the database connection. Actual database access is handled by
 * Login and DocumentManager.
 */
public abstract class Database {

	//static public Database getInstance();
	
	/** Shutdown the database */
	public abstract void close();
	
}