/*
 * jQuery 
 * version: 1.0 (2008/11/13)
 * @requires jQuery v1.2.6
 * @todo: Test it with previous jQuery versions
 * @author: sebastien rannou - http://www.aimxhaisse.com
 *
 * licensed under the MIT: http://www.opensource.org/licenses/mit-license.php
 *
 * Revision: 1
 */

jQuery.fn.james = function (url_to_call, options) {
    var that = jQuery(this),
        results_set = [],
	old_value = that.val();
        current_hovered_rank = 0,
        keyEvents = [
            {keycode: 38, action: function () { keyEventKeyUp(); }},
            {keycode: 40, action: function () { keyEventKeyDown(); }},
            {keycode: 13, action: function () { keyEventEnter(); }},
            {keycode: 27, action: function () { keyEventEsc(); }}
        ],
        ul_element = false,
    	o = jQuery.extend({
        onKeystroke:    function (data) {
            return data;
        },
        onSelect:       function (dom_value, json_obj) {
            that.attr("value", old_value + " " + results_set[current_hovered_rank].text);
        },
        keydelay:       300,
        minlength:      3,
        method:         "get",
        varname:        "input_content",
        params:         ""
    },  options || {});
    
    /*
     * This method performs DOM initialization
     * Creates a UL with an Unique ID and push it to DOM
     * It's called only once
     */
    (function initDOM() {
        var ul_id = false;
        var ul_node = document.createElement("ul");

        // Performs generation of an unique ID
        var genUniqueId = function () {
            var result = "ul_james_" + Math.round(Math.random() * 424242);

            if (jQuery("#" + result).length > 0)
            {
                result = genUniqueId();
            }
            return result;
        };

        ul_id = genUniqueId();

        jQuery(ul_node).attr("id", ul_id).addClass("ul_james");
        that.after(ul_node);
        // Creating a shortcut
        ul_element = jQuery("#" + ul_id);
        ul_element.hide();
    })();
    
    /*
	 * This method performs CSS initialization
     * It sets position's <ul> (especially for IE6)
     * And sets result's width to input's width
     * Because offset can be changed, it's called each time
     * the dom is modified
     */
    var initCSS = function initCSS() {
        var input_offset = that.offset();

        ul_element.css({
                        top:        input_offset.top + that.outerHeight(),
                        width:      that.outerWidth(),
                        left:       input_offset.left,
                        position:   "absolute"
                        });
    }
    
    /*
     * This is used to avoid form to be submit
     * when the user press Enter to make his choice
     * @TODO: When user has already made his choice, submit it
     */
    that.keydown(function (event) {
        if (event.keyCode === 13)
        {
            return false;
        }
    });
    
    /*
     * This method performs Keyboard Events
     * @TODO: Build actions for more key events (CTRL? ALT?)
     * or recognize ASCII codes?
     */
    //Timer's ID of next AJAX call
    var keyevent_current_timer = false;
    
    that.keyup(function(event) {
        var is_specific_action = false;
        // Check if a specific action is linked to the keycode
        for (var i = 0; keyEvents[i]; i++)
        {
            if (event.keyCode === keyEvents[i].keycode)
            {
                is_specific_action = true;
                keyEvents[i].action();
                break;
            }
        }
        // If it's not a specific action
        if (is_specific_action === false)
        {
            // Unset last timeout if it was defined
            if (keyevent_current_timer !== false)
            {
                window.clearTimeout(keyevent_current_timer);
                keyevent_current_timer = false;
            }
            // Set a now timeout with an AJAX call inside
            keyevent_current_timer = window.setTimeout(function () { 
                ajaxUpdate();
            }, o.keydelay);
        }
	});
    
    /*
     * This method performs AJAX calls
     */
    var ajaxUpdate = function () {
        //var value_to_send = that.attr("value");
	var value_to_send = that.val();
	var parts = value_to_send.split(" ")
	var old_values = [];
	if(parts.length > 1){
	 value_to_send = ""
	 for(var i in parts){
	  if(i == parts.length - 1){
	   value_to_send = parts[i];
	  }else{
           old_values.push(parts[i]);
	  }
	 }
	}
	old_value = old_values.join(" ");
        // Check length of input's value
        if (value_to_send.length > 0 &&
            (o.minlength === false ||
            value_to_send.length >= o.minlength))
        {
	    $.get("/autocomplete",{q:value_to_send},function(data){
		  var r = eval('(' + data + ')');
		  var arr = r.result;
		 	
                    results_set = [];
                    current_hovered = 0;
                    for (var i in arr)
                    {
                                results_set
                                .push({text: arr[i]});
                    }
                    updateDom();
            });
        }
        else
        {
            cleanResults();
        }
    }
    
    /*
     * This method performs the display of the results set
     * Basically called when an event has been made
     */
    var updateDom = function() {
    	jQuery(ul_element).empty();
    	var is_empty = true;

        initCSS();
        for (var i in results_set)
        {
            if (results_set[i] !== null)
            {
                var li_elem = document.createElement("li");

                jQuery(li_elem).addClass("li_james");
                if (i == (current_hovered_rank % results_set.length))
                {
                    jQuery(li_elem).addClass("li_james_hovered");
                }
                jQuery(li_elem).append(results_set[i].text);
                jQuery(ul_element).append(li_elem);
                bind_elem_mouse_hover(li_elem, i);
                is_empty = false;
            }
        }
        if (is_empty)
        {
            jQuery(ul_element).hide();
        }
        else
        {
            jQuery(ul_element).show();
        }
    }
    
    /*
     * This method performs the ability to
     * select a result with mouse
     */
    var bind_elem_mouse_hover = function (elem, i) {
	   jQuery(elem).hover(function() {
            jQuery(ul_element)
            .find(".li_james_hovered")
            .removeClass("li_james_hovered");
            jQuery(elem).addClass("li_james_hovered");
            current_hovered_rank = i;
	    }, function() {
            jQuery(elem).removeClass("li_james_hovered");
            current_hovered_rank = 0;
	    });
        jQuery(elem).click(function() {
		  keyEventEnter();
        });
    }
    
    /*
     * This method clears results in DOM & JS
     */
    var cleanResults = function () {
        jQuery(ul_element).empty();
        jQuery(ul_element).hide();
        results_set = [];
        current_hovered_rank = 0;
    }
    
    /*
     * Key event actions
     */
    
    // Moving up into results set
    var keyEventKeyUp = function () {
        if (current_hovered_rank > 0)
        {
            current_hovered_rank--;
        }
        else if (results_set.length)
        {
                current_hovered_rank = results_set.length - 1;
        }
        updateDom();
    }
    
    // Moving down into resuls set
    var keyEventKeyDown = function () {
        if (current_hovered_rank < (results_set.length - 1))
        {
            current_hovered_rank++;
        }
        else
        {
            current_hovered_rank = 0;
        }
        updateDom();
    }
    
    // Selecting a set (onSelect function is called there)
    var keyEventEnter = function () {
        if (results_set.length > 0)
        {
           that.attr("value",
                o.onSelect(old_value + results_set[current_hovered_rank].text,
                           old_value + results_set[current_hovered_rank].json));
        }
        cleanResults();
    }
    
    // Removing results set
    var keyEventEsc = function () {
        that.attr("value", old_value + "");
        cleanResults();
    }
};
