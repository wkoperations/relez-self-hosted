module ApplicationHelper
  def status_bg_class(status)
    case status
    when "success"
      "bg-green-50"
    when "failed"
      "bg-red-50"
    when "running"
      "bg-blue-50"
    when "queued"
      "bg-gray-50"
    else
      "bg-gray-50"
    end
  end

  def status_text_class(status)
    case status
    when "success"
      "text-green-700"
    when "failed"
      "text-red-700"
    when "running"
      "text-blue-700"
    when "queued"
      "text-gray-700"
    else
      "text-gray-700"
    end
  end

  def status_ring_class(status)
    case status
    when "success"
      "ring-green-600/20"
    when "failed"
      "ring-red-600/20"
    when "running"
      "ring-blue-600/20"
    when "queued"
      "ring-gray-600/20"
    else
      "ring-gray-600/20"
    end
  end

  def status_icon(status)
    case status
    when "success"
      '<svg class="h-6 w-6 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
      </svg>'.html_safe
    when "failed"
      '<svg class="h-6 w-6 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
      </svg>'.html_safe
    when "running"
      '<svg class="h-6 w-6 text-blue-600 animate-spin" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
      </svg>'.html_safe
    when "queued"
      '<svg class="h-6 w-6 text-gray-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>'.html_safe
    else
      '<svg class="h-6 w-6 text-gray-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>'.html_safe
    end
  end

  def status_badge_class(status)
    case status
    when "success"
      "inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20"
    when "failed"
      "inline-flex items-center rounded-md bg-red-50 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/20"
    when "running"
      "inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-600/20"
    else
      "inline-flex items-center rounded-md bg-gray-50 px-2 py-1 text-xs font-medium text-gray-700 ring-1 ring-inset ring-gray-600/20"
    end
  end
end
