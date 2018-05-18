package codeu.model.data;

import java.time.Instant;
import java.util.UUID;

public interface FeedEntry {
    /** Returns the ID of this Message. */
    public UUID getId();

    /** Returns the creation time of this Message. */
    public Instant getCreationTime();
}
