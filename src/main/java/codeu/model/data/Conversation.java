// Copyright 2017 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package codeu.model.data;

import java.time.Instant;
import java.util.UUID;
import java.util.ArrayList;

/**
 * Class representing a conversation, which can be thought of as a chat room. Conversations are
 * created by a User and contain Messages.
 */
public class Conversation implements FeedEntry{
  public final UUID id;
  public final UUID owner;
  public final Instant creation;
  public final String title;
  public ArrayList<String> tags;

  /**
   * Constructs a new Conversation.
   *
   * @param id the ID of this Conversation
   * @param owner the ID of the User who created this Conversation
   * @param title the title of this Conversation
   * @param creation the creation time of this Conversation
   */
  public Conversation(UUID id, UUID owner, String title, Instant creation) {
    this.id = id;
    this.owner = owner;
    this.creation = creation;
    this.title = title;
    this.tags = new ArrayList<String>();
  }

  public Conversation(UUID id, UUID owner, String title, Instant creation,
                      ArrayList<String> tags) {
    this.id = id;
    this.owner = owner;
    this.creation = creation;
    this.title = title;
    if(tags == null)
      this.tags = new ArrayList<String>();
    else
      this.tags = tags;
  }


  /** Returns the ID of this Conversation. */
  public UUID getId() {
    return id;
  }

  /** Returns the ID of the User who created this Conversation. */
  public UUID getOwnerId() {
    return owner;
  }

  /** Returns the title of this Conversation. */
  public String getTitle() {
    return title;
  }

  /** Returns the creation time of this Conversation. */
  public Instant getCreationTime() {
    return creation;
  }

  /** Returns the tags of this conversation as an arraylist. */
  public ArrayList<String> getTags() {
    return tags;
  }

  /** Returns the tags of this conversation as a string separated by commas. */
  public String getStringTags() {
    String stringtags = "";
    if (tags.size() > 0)
    {
      stringtags = tags.get(0);
      for(int i = 1; i< tags.size(); i++)
        stringtags += ", " + tags.get(i);
    }
    return stringtags;
  }

  /** Adds a string to the tags of this Conversation. */
  public void addTag(String tag) {
    if(tags.indexOf(tag)!=0 && !(tag==null) && !(tag.trim().isEmpty()))
        tags.add(tag.toLowerCase());
  }
}
