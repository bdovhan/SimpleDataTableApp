public class Pluck {
    /**
	 * Equivalent to Javascript `x || y` syntax. If x is not null, returns x, otherwise y.
	 * @param Object x : the first argument to return if it is not null
	 * @param Object y: the second argument returned if x is null
	 * @return Object: x either y
	 */
	public static Object either(Object x, Object y) {
		return x != null ? x : y;
	}
	/**
     * Plucks Id values from records
     * @param List<SObject> records: sObject records
     * @return List<Id> : records Id values
     */
	public static List<Id> ids( List<SObject> records ) {
		List<String> keys = new List<String>();
		if ( records != null ){
			for ( SObject rec: records ) {
				keys.add( rec.Id );
			}
		}
		return keys;
	}
}