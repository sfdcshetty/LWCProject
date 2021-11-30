/**
 * This is the TriggerInterface class. This interface
 * contains methods for master trigger handler classes
 * to implement.
 *
 * @author Craig Isakson -- Sundog Interactive
 * @date 01/2016
 *
 */
public interface TriggerInterface{
    void beforeInsert();
    void beforeUpdate();
    void beforeDelete();
    void afterInsert();
    void afterUpdate();
    void afterDelete();
    void finish();
}