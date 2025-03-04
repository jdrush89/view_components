# frozen_string_literal: true

require "system/test_case"

module Alpha
  class IntegrationActionMenuTest < System::TestCase
    def test_dynamic_labels
      visit_preview(:single_select_with_internal_label)
      assert_selector("action-menu button[aria-controls]", text: "Menu: Quote reply")

      find("action-menu button[aria-controls]").click
      find("action-menu ul li:first-child").click

      assert_selector("action-menu button[aria-controls]", text: "Menu: Copy link")

      find("action-menu button[aria-controls]").click
      find("action-menu ul li:first-child").click

      assert_selector("action-menu button[aria-controls]", text: "Menu")
    end

    def test_anchor_align
      visit_preview(:align_end)

      find("action-menu button[aria-controls]").click

      assert_selector("anchored-position[align=end]")
    end

    def test_action_onclick
      visit_preview(:with_actions)

      find("action-menu button[aria-controls]").click

      accept_alert do
        find("action-menu ul li:first-child").click
      end
    end

    def test_action_keydown
      visit_preview(:with_actions)

      page.evaluate_script(<<~JS)
        document.querySelector('action-menu button[aria-controls]').focus()
      JS

      accept_alert do
        # open menu, "click" on first item
        page.driver.browser.keyboard.type(:enter, :enter)
      end
    end

    def test_action_anchor
      visit_preview(:with_actions)

      find("action-menu button[aria-controls]").click
      find("action-menu ul li:nth-child(2)").click

      assert_selector ".action-menu-landing-page", text: "Hello world!"
    end

    def test_action_anchor_keydown
      visit_preview(:with_actions)

      page.evaluate_script(<<~JS)
        document.querySelector('action-menu button[aria-controls]').focus()
      JS

      # open menu, arrow down to second item, "click" second item
      page.driver.browser.keyboard.type(:enter, :down, :enter)

      assert_selector ".action-menu-landing-page", text: "Hello world!"
    end

    def stub_clipboard!
      page.evaluate_script(<<~JS)
        (() => {
          navigator.clipboard.writeText = async (text) => {
            this.text = text;
            return Promise.resolve(null);
          };

          navigator.clipboard.readText = async () => {
            return Promise.resolve(this.text);
          };
        })()
      JS
    end

    def read_clipboard
      page.evaluate_async_script(<<~JS)
        const [done] = arguments;
        navigator.clipboard.readText().then(done).catch((e) => done(e));
      JS
    end

    def test_action_clipboard_copy
      visit_preview(:with_actions)

      stub_clipboard!

      find("action-menu button[aria-controls]").click
      find("action-menu ul li:nth-child(3)").click

      assert_equal read_clipboard, "Text to copy"
    end

    def test_action_clipboard_copy_keydown
      visit_preview(:with_actions)

      stub_clipboard!

      page.evaluate_script(<<~JS)
        document.querySelector('action-menu button[aria-controls]').focus()
      JS

      # open menu, arrow down to third item, "click" third item
      page.driver.browser.keyboard.type(:enter, :down, :down, :enter)

      assert_equal read_clipboard, "Text to copy"
    end

    def test_first_item_is_focused_on_invoker_keydown
      visit_preview(:with_actions)

      page.evaluate_script(<<~JS)
        document.querySelector('action-menu button[aria-controls]').focus()
      JS

      # open menu
      page.driver.browser.keyboard.type(:enter)

      assert_equal page.evaluate_script("document.activeElement").text, "Alert"
    end

    def test_opens_dialog
      visit_preview(:opens_dialog)

      find("action-menu button[aria-controls]").click
      find("action-menu ul li:nth-child(2)").click

      assert_selector "modal-dialog#my-dialog"

      # opening the dialog should close the menu
      refute_selector "action-menu ul li"
    end

    def test_opens_dialog_on_keydown
      visit_preview(:opens_dialog)

      page.evaluate_script(<<~JS)
        document.querySelector('action-menu button[aria-controls]').focus()
      JS

      # open menu, arrow down to second item, "click" second item
      page.driver.browser.keyboard.type(:enter, :down, :enter)

      assert_selector "modal-dialog#my-dialog"
    end

    def test_single_select_form_submission
      visit_preview(:single_select_form, route_format: :json)

      find("action-menu button[aria-controls]").click
      find("action-menu ul li:first-child").click

      find("input[type=submit]").click

      # for some reason the JSON response is wrapped in HTML, I have no idea why
      response = JSON.parse(find("pre").text)
      assert_equal "fast_forward", response["value"]
    end

    def test_single_select_form_uses_label_if_no_value_provided
      visit_preview(:single_select_form, route_format: :json)

      find("action-menu button[aria-controls]").click
      find("action-menu ul li:last-child").click

      find("input[type=submit]").click

      # for some reason the JSON response is wrapped in HTML, I have no idea why
      response = JSON.parse(find("pre").text)
      assert_equal "Resolve", response["value"]
    end

    def test_multiple_select_form_submission
      visit_preview(:multiple_select_form, route_format: :json)

      find("action-menu button[aria-controls]").click
      find("action-menu ul li:first-child").click
      find("action-menu ul li:nth-child(2)").click

      # close the menu to reveal the submit button
      page.driver.browser.keyboard.type(:escape)

      find("input[type=submit]").click

      # for some reason the JSON response is wrapped in HTML, I have no idea why
      response = JSON.parse(find("pre").text)
      assert_equal %w[fast_forward recursive], response["value"]
    end

    def test_multiple_select_form_uses_label_if_no_value_provided
      visit_preview(:multiple_select_form, route_format: :json)

      find("action-menu button[aria-controls]").click
      find("action-menu ul li:first-child").click
      find("action-menu ul li:last-child").click

      # close the menu to reveal the submit button
      page.driver.browser.keyboard.type(:escape)

      find("input[type=submit]").click

      # for some reason the JSON response is wrapped in HTML, I have no idea why
      response = JSON.parse(find("pre").text)
      assert_equal %w[fast_forward Resolve], response["value"]
    end

    def test_individual_items_can_submit_post_requests_via_forms
      visit_preview(:with_actions)

      find("action-menu button[aria-controls]").click
      find("action-menu ul li:last-child").click

      assert_equal page.text, 'You selected "bar"'
    end

    def test_deferred_loading
      visit_preview(:with_deferred_content)

      find("action-menu button[aria-controls]").click

      assert_selector "action-menu ul li", text: "Copy link"
      assert_selector "action-menu ul li", text: "Quote reply"
      assert_selector "action-menu ul li", text: "Reference in new issue"

      assert_equal page.evaluate_script("document.activeElement").text, "Copy link"
    end

    def test_deferred_loading_on_keydown
      visit_preview(:with_deferred_content)

      page.evaluate_script(<<~JS)
        document.querySelector('action-menu button[aria-controls]').focus()
      JS

      page.driver.browser.keyboard.type(:enter)

      # wait for menu to load
      assert_selector "action-menu ul li", text: "Copy link"
      assert_equal page.evaluate_script("document.activeElement").text, "Copy link"
    end

    def test_opening_second_menu_closes_first_menu
      visit_preview(:two_menus)

      find("#menu-1-button").click

      assert_selector "action-menu ul li", text: "Eat a dot"
      refute_selector "action-menu ul li", text: "Stomp a turtle"

      find("#menu-2-button").click

      refute_selector "action-menu ul li", text: "Eat a dot"
      assert_selector "action-menu ul li", text: "Stomp a turtle"
    end
  end
end
