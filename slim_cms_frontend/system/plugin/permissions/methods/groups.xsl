<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://exslt.org/strings">
	
    <!-- //Permissions > Group Plugin -->
	<xsl:template match="/config/plugin[@plugin = 'permissions'][@method = 'groups']">
        <xsl:choose>
            <xsl:when test="@mode = 'add'">
                <xsl:call-template name="add" />
            </xsl:when>
            <xsl:when test="@mode = 'edit'">
                <xsl:call-template name="edit" />
            </xsl:when>
            <xsl:when test="@mode = 'delete'">
                <xsl:call-template name="delete" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="index" />
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>

    <!-- //Index group mode -->
    <xsl:template name="index">
        <div class="row">
            <div class="col-md-12">
                <table class="table table-striped data-table static" data-column-defs="[{{&quot;sortable&quot;: false, &quot;targets&quot;: [1]}}]">
                    <thead>
                        <tr>
                            <th>Group</th>
                            <th>Slug</th>
                            <th>Description</th>
                            <th class="text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="groups/group">
                            <tr>
                                <td>
                                    <xsl:value-of select="@group" />
                                </td>
                                <td>
                                    <xsl:value-of select="@slug" />
                                </td>
                                <td>
                                    <xsl:value-of select="@description" />
                                </td>
                                <td class="text-right" width="100px">
                                    <a href="{concat(@url,'edit/', @user_defined_group_id)}" role="button" class="btn btn-base btn-space" title="Edit">
                                        <i class="fa fa-pencil"></i>
                                    </a>
                                    <a href="{concat(@url,'delete/', @user_defined_group_id)}" role="button" class="btn btn-danger" title="Delete" data-confirm="Are you sure to delete this item?">
                                        <i class="fa fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
            </div>
        </div>

        <hr />
        <xsl:call-template name="index-buttons" />
    </xsl:template>

    <!-- //Index buttons -->
    <xsl:template name="index-buttons">
        <div class="row">
            <div class="col-md-2">
                <a href="{concat(@url,'add/')}" class="btn btn-success btn-block" role="button">Add Group</a>
            </div>
        </div>
    </xsl:template>

    <!-- //Add group mode -->
    <xsl:template name="add">
        <h3>Add Group</h3>
        <xsl:call-template name="group-form" />
    </xsl:template>

    <!-- //Edit group mode -->
    <xsl:template name="edit">
        <h3>Edit Group</h3>
        <xsl:call-template name="group-form" />
    </xsl:template>

    <!-- //Delete group mode -->
    <xsl:template name="delete">
        <h3>Delete Group</h3>
    </xsl:template>

    <!-- //Add/Edit group form -->
    <xsl:template name="group-form">
        <form method="post" data-parsley-validate="data-parsley-validate">
            <input type="hidden" name="mode" value="group-{@mode}" />
            <div class="row">
                <div class="col-md-12">
                    <div class="form-group">
                        <label class="control-label" for="name">Name *</label>
                        <input type="text" class="form-control" id="name" name="name" required="required">
                            <xsl:attribute name="value">
                                <xsl:choose>
                                    <xsl:when test="input/@name">
                                        <xsl:value-of select="input/@name" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="groups/group[@user_defined_group_id = current()/@group_id]/@name" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>   
                        </input>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="form-group">
                        <label class="control-label" for="name">Slug</label>
                        <input type="text" class="form-control" id="slug" name="slug">
                            <xsl:attribute name="value">
                                <xsl:choose>
                                    <xsl:when test="input/@slug">
                                        <xsl:value-of select="input/@slug" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="groups/group[@user_defined_group_id = current()/@group_id]/@slug" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>   
                        </input>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="form-group">
                        <label class="control-label" for="description">Description</label>
                        <textarea class="form-control" id="description" name="description">
                            <xsl:choose>
                                <xsl:when test="input/@description">
                                    <xsl:value-of select="input/@description" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="groups/group[@user_defined_group_id = current()/@group_id]/@description" />
                                </xsl:otherwise>
                            </xsl:choose>                  
                        </textarea>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="form-group">
                        <label class="control-label" for="parent_group_id">Parent Group</label>
                        <select class="form-control chosen-select" name="parent_group_id">
                            <option value="0">No Parent Group</option>
                            <xsl:for-each select="groups/group[@user_defined_group_id != current()/@group_id]">
                                <xsl:sort select="@group" />
                                <option value="{@user_defined_group_id}">
                                    <xsl:choose>
                                        <xsl:when test="../group[@user_defined_group_id = ../../@group_id]/@parent_group_id = current()/@user_defined_group_id">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:when>
                                    </xsl:choose>                                        
                                    <xsl:value-of select="@group" />
                                </option>
                            </xsl:for-each>
                        </select>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="form-group">
                        <label class="control-label" for="client_contact_id">Members</label>
                        <select class="form-control chosen-select" name="group_members[]" multiple="multiple">
                            <xsl:for-each select="clients/client">
                                <xsl:sort select="@company_name" />
                                <option value="{@client_id}">
                                    <xsl:choose>
                                        <xsl:when test="../../members/member[@client_id = current()/@client_id]">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:when>
                                    </xsl:choose>                                        
                                    <xsl:value-of select="@company_name" />
                                </option>
                            </xsl:for-each>
                        </select>        
                    </div>
                </div>
            </div>

            <hr />
            <xsl:call-template name="group-form-buttons" />
        </form>
    </xsl:template>

    <!-- //Group form buttons -->
    <xsl:template name="group-form-buttons">
        <div class="row">
            <div class="col-md-2">
                <button type="submit" class="btn btn-success btn-block" role="button" title="Save">Save</button>
            </div>
            <div class="col-md-2">
                <a href="{@url}" class="btn btn-warning btn-block" role="button" title="Cancel">Cancel</a>
            </div>

            <xsl:if test="@mode = 'edit'">
                <div class="col-md-2">
                    <a href="{concat(@url,'delete/', @group_id)}" class="btn btn-danger btn-block btn-delete" role="button" title="Delete" data-confirm="Are you sure to delete this item?">Delete</a>
                </div>
            </xsl:if>
        </div>
    </xsl:template>
	
</xsl:stylesheet>