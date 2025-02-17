require "test_helper"

class OldNodesControllerTest < ActionDispatch::IntegrationTest
  def test_routes
    assert_routing(
      { :path => "/node/1/history/2", :method => :get },
      { :controller => "old_nodes", :action => "show", :id => "1", :version => "2" }
    )
  end

  def test_visible_with_one_version
    node = create(:node, :with_history)
    get old_node_path(node, 1)
    assert_response :success
    assert_template "old_nodes/show"
    assert_template :layout => "map"
    assert_select "h4", /^Version/ do
      assert_select "a[href='#{old_node_path node, 1}']", :count => 0
    end
    assert_select ".secondary-actions a[href='#{node_version_path node, 1}']", :count => 1
    assert_select ".secondary-actions a[href='#{node_path node}']", :count => 1
    assert_select ".secondary-actions a[href='#{node_history_path node}']", :count => 1
  end

  def test_visible_with_two_versions
    node = create(:node, :with_history, :version => 2)
    get old_node_path(node, 1)
    assert_response :success
    assert_template "old_nodes/show"
    assert_template :layout => "map"
    assert_select "h4", /^Version/ do
      assert_select "a[href='#{old_node_path node, 1}']", :count => 0
    end
    assert_select ".secondary-actions a[href='#{node_version_path node, 1}']", :count => 1
    assert_select ".secondary-actions a[href='#{node_path node}']", :count => 1
    assert_select ".secondary-actions a[href='#{node_history_path node}']", :count => 1
    assert_select ".secondary-actions a[href='#{old_node_path node, 2}']", :count => 1

    get old_node_path(node, 2)
    assert_response :success
    assert_template "old_nodes/show"
    assert_template :layout => "map"
    assert_select "h4", /^Version/ do
      assert_select "a[href='#{old_node_path node, 2}']", :count => 0
    end
    assert_select ".secondary-actions a[href='#{node_version_path node, 2}']", :count => 1
    assert_select ".secondary-actions a[href='#{node_path node}']", :count => 1
    assert_select ".secondary-actions a[href='#{node_history_path node}']", :count => 1
    assert_select ".secondary-actions a[href='#{old_node_path node, 1}']", :count => 1
  end

  def test_redacted
    node = create(:node, :with_history, :deleted, :version => 2)
    node_v1 = node.old_nodes.find_by(:version => 1)
    node_v1.redact!(create(:redaction))
    get old_node_path(node, 1)
    assert_response :success
    assert_template "old_nodes/show"
    assert_template :layout => "map"
    assert_select ".secondary-actions a[href='#{node_path node}']", :count => 1
    assert_select ".secondary-actions a[href='#{old_node_path node, 1}']", :count => 0
    assert_select ".secondary-actions a[href='#{node_version_path node, 1}']", :count => 0
  end

  def test_not_found
    get old_node_path(0, 0)
    assert_response :not_found
    assert_template "old_nodes/not_found"
    assert_template :layout => "map"
    assert_select "#sidebar_content", /node #0 version 0 could not be found/
  end
end
