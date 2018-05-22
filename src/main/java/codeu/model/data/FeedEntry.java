package codeu.model.data;

import java.time.Instant;
import java.util.UUID;

/**
 * Interface representing anything that has a creation time and a unique identifier.
 * Used for aggregating and performing operations on events that happen on the site.
 */
public interface FeedEntry {
  /**
   * Returns the ID of this Message.
   */
  UUID getId();

  /**
   * Returns the creation time of this Message.
   */
  Instant getCreationTime();
}
