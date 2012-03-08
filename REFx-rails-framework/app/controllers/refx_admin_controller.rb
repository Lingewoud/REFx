class RefxAdminController < ApplicationController

  def flushlog
	  system('rake log:clear')
	  respond_to do |format|
		  format.html { redirect_to(root_url) }
		  format.xml  { head :ok }
	  end
  end

  def startbackgroundrb
  end

  def stopbackgroundrb
  end

  def restartbackgroundrb
  end
end
